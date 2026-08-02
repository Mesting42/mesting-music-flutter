import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../domain/app_update_models.dart';
import 'app_update_platform.dart';

typedef UpdateDownloadProgress =
    void Function(int receivedBytes, int totalBytes);
typedef UpdateDirectoryProvider = Future<Directory> Function();

class UpdateDownloadCancellationToken {
  bool _cancelled = false;
  Future<void> Function()? _cancelActiveRead;

  bool get isCancelled => _cancelled;

  Future<void> cancel() async {
    if (_cancelled) return;
    _cancelled = true;
    await _cancelActiveRead?.call();
  }

  Future<void> _attach(Future<void> Function() cancelActiveRead) async {
    _cancelActiveRead = cancelActiveRead;
    if (_cancelled) await cancelActiveRead();
  }

  void _detach() => _cancelActiveRead = null;
}

class AppUpdateDownloadSnapshot {
  const AppUpdateDownloadSnapshot({
    required this.receivedBytes,
    required this.totalBytes,
    this.completedPath,
  });

  final int receivedBytes;
  final int totalBytes;
  final String? completedPath;

  bool get isComplete => completedPath != null;
}

class AppUpdateRepository {
  AppUpdateRepository({
    required http.Client client,
    required AppUpdatePlatform platform,
    Uri? manifestUrl,
    UpdateDirectoryProvider? directoryProvider,
  }) : _client = client,
       _platform = platform,
       _manifestUrl = manifestUrl ?? Uri.parse(defaultManifestUrl),
       _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  static const defaultManifestUrl = String.fromEnvironment(
    'APP_UPDATE_MANIFEST_URL',
    defaultValue:
        'https://mesting-d5gm7tuhxacddccfb-1331507389.tcloudbaseapp.com/releases/android/latest.json',
  );
  static const expectedPackageName = 'com.mesting.music';
  static const _maxManifestBytes = 1024 * 1024;
  static const _maxApkBytes = 350 * 1024 * 1024;
  static const _progressFlushBytes = 256 * 1024;

  final http.Client _client;
  final AppUpdatePlatform _platform;
  final Uri _manifestUrl;
  final UpdateDirectoryProvider _directoryProvider;

  Future<AppVersionInfo> currentVersion() => _platform.currentVersion();

  Future<AppUpdateCheckResult> check() async {
    try {
      final current = await currentVersion();
      if (current.packageName != expectedPackageName) {
        throw const AppUpdateException('当前安装包标识不受支持', code: 'package');
      }
      final requestUrl = _manifestUrl.replace(
        queryParameters: {
          ..._manifestUrl.queryParameters,
          't': '${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      final response = await _client
          .get(requestUrl, headers: const {'accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw AppUpdateException(
          '更新服务暂时不可用（${response.statusCode}）',
          code: 'manifest_http',
        );
      }
      if (response.bodyBytes.length > _maxManifestBytes) {
        throw const AppUpdateException('更新清单大小异常', code: 'manifest_size');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('更新清单不是 JSON 对象');
      }
      final manifest = AppUpdateManifest.fromJson(decoded);
      if (manifest.packageName != expectedPackageName) {
        throw const AppUpdateException('更新包与当前应用不匹配', code: 'package');
      }
      if (manifest.sizeBytes > _maxApkBytes) {
        throw const AppUpdateException('更新包大小异常', code: 'apk_size');
      }
      return AppUpdateCheckResult(currentVersion: current, manifest: manifest);
    } on AppUpdateException {
      rethrow;
    } on FormatException {
      throw const AppUpdateException('更新清单格式无效', code: 'manifest');
    } on Object {
      throw const AppUpdateException('无法连接更新服务，请检查网络', code: 'network');
    }
  }

  Future<String> download(
    AppUpdateManifest manifest, {
    required UpdateDownloadProgress onProgress,
    UpdateDownloadCancellationToken? cancellationToken,
  }) async {
    final files = await _filesFor(manifest);
    final snapshot = await inspectDownload(manifest);
    if (snapshot.completedPath case final completedPath?) {
      onProgress(manifest.sizeBytes, manifest.sizeBytes);
      return completedPath;
    }
    var receivedBytes = snapshot.receivedBytes;
    onProgress(receivedBytes, manifest.sizeBytes);
    _throwIfCancelled(cancellationToken);
    try {
      final request = http.Request('GET', manifest.apkUrl)
        ..headers['accept'] = 'application/vnd.android.package-archive';
      if (receivedBytes > 0) {
        request.headers['range'] = 'bytes=$receivedBytes-';
      }
      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      var append = false;
      var verifyFullResponsePrefix = false;
      if (receivedBytes > 0 && response.statusCode == 206) {
        if (!_validContentRange(
          response.headers['content-range'],
          receivedBytes,
          manifest.sizeBytes,
        )) {
          throw const AppUpdateException('更新服务返回的续传范围无效', code: 'range');
        }
        append = true;
      } else if (receivedBytes > 0 && response.statusCode == 200) {
        // Some static-hosting gateways advertise byte ranges but still return
        // the full object. Keep the persisted progress, verify the repeated
        // prefix byte-for-byte, then append only the unseen suffix.
        append = true;
        verifyFullResponsePrefix = true;
      } else if (response.statusCode == 200) {
        receivedBytes = 0;
        await _deleteIfPresent(files.partial);
        onProgress(0, manifest.sizeBytes);
      } else if (receivedBytes == 0 &&
          response.statusCode == 206 &&
          _validContentRange(
            response.headers['content-range'],
            0,
            manifest.sizeBytes,
          )) {
        receivedBytes = 0;
      } else {
        throw AppUpdateException(
          '安装包下载失败（${response.statusCode}）',
          code: 'download_http',
        );
      }

      final advertisedBytes = response.contentLength;
      if (advertisedBytes != null &&
          (advertisedBytes > _maxApkBytes ||
              (response.statusCode == 206
                  ? receivedBytes + advertisedBytes > manifest.sizeBytes
                  : advertisedBytes > manifest.sizeBytes))) {
        throw const AppUpdateException('安装包大小异常', code: 'apk_size');
      }

      var lastReportedBytes = receivedBytes;
      var prefixBytesRemaining = verifyFullResponsePrefix ? receivedBytes : 0;
      RandomAccessFile? prefixReader = verifyFullResponsePrefix
          ? await files.partial.open()
          : null;
      RandomAccessFile? output = verifyFullResponsePrefix
          ? null
          : await files.partial.open(
              mode: append ? FileMode.append : FileMode.write,
            );
      final iterator = StreamIterator<List<int>>(
        response.stream.timeout(const Duration(seconds: 30)),
      );
      await cancellationToken?._attach(iterator.cancel);
      try {
        while (await iterator.moveNext()) {
          _throwIfCancelled(cancellationToken);
          final chunk = iterator.current;
          var payloadOffset = 0;
          if (prefixBytesRemaining > 0) {
            final compareLength = chunk.length < prefixBytesRemaining
                ? chunk.length
                : prefixBytesRemaining;
            final expected = await prefixReader!.read(compareLength);
            if (!_sameBytes(expected, chunk, compareLength)) {
              throw const AppUpdateException('更新包内容已变化，请重新下载', code: 'range');
            }
            prefixBytesRemaining -= compareLength;
            payloadOffset = compareLength;
            if (prefixBytesRemaining == 0) {
              await prefixReader.close();
              prefixReader = null;
              output = await files.partial.open(mode: FileMode.append);
            }
          }
          if (payloadOffset == chunk.length) continue;
          final payload = payloadOffset == 0
              ? chunk
              : chunk.sublist(payloadOffset);
          receivedBytes += payload.length;
          if (receivedBytes > _maxApkBytes ||
              receivedBytes > manifest.sizeBytes) {
            throw const AppUpdateException('安装包大小异常', code: 'apk_size');
          }
          await output!.writeFrom(payload);
          if (receivedBytes - lastReportedBytes >= _progressFlushBytes ||
              receivedBytes == manifest.sizeBytes) {
            await output.flush();
            lastReportedBytes = receivedBytes;
            onProgress(receivedBytes, manifest.sizeBytes);
          }
        }
      } finally {
        cancellationToken?._detach();
        await iterator.cancel();
        await prefixReader?.close();
        await output?.flush();
        await output?.close();
      }

      _throwIfCancelled(cancellationToken);
      final persistedBytes = await files.partial.length();
      if (persistedBytes < manifest.sizeBytes) {
        onProgress(persistedBytes, manifest.sizeBytes);
        throw const AppUpdateException('下载已中断，进度已保留', code: 'interrupted');
      }
      if (persistedBytes > manifest.sizeBytes) {
        await _deleteIfPresent(files.partial);
        throw const AppUpdateException('安装包大小异常', code: 'apk_size');
      }
      onProgress(persistedBytes, manifest.sizeBytes);
      return _finalizeDownload(manifest, files);
    } on AppUpdateException catch (error) {
      if (error.code == 'sha256' ||
          error.code == 'apk_size' ||
          error.code == 'range') {
        await _deleteIfPresent(files.partial);
      }
      rethrow;
    } on Object {
      final persistedBytes = await _safeLength(files.partial);
      if (persistedBytes > 0) {
        onProgress(persistedBytes, manifest.sizeBytes);
      }
      throw const AppUpdateException('下载已中断，进度已保留，请稍后继续', code: 'interrupted');
    }
  }

  Future<AppUpdateDownloadSnapshot> inspectDownload(
    AppUpdateManifest manifest,
  ) async {
    final files = await _filesFor(manifest);
    await _clearOldDownloads(
      files.directory,
      keep: {files.target.path, files.partial.path},
    );

    if (await files.target.exists()) {
      final targetLength = await files.target.length();
      if (targetLength == manifest.sizeBytes &&
          await _matchesDigest(files.target, manifest.sha256)) {
        return AppUpdateDownloadSnapshot(
          receivedBytes: manifest.sizeBytes,
          totalBytes: manifest.sizeBytes,
          completedPath: files.target.path,
        );
      }
      await _deleteIfPresent(files.target);
    }

    if (!await files.partial.exists()) {
      return AppUpdateDownloadSnapshot(
        receivedBytes: 0,
        totalBytes: manifest.sizeBytes,
      );
    }
    final partialLength = await files.partial.length();
    if (partialLength > manifest.sizeBytes) {
      await _deleteIfPresent(files.partial);
      return AppUpdateDownloadSnapshot(
        receivedBytes: 0,
        totalBytes: manifest.sizeBytes,
      );
    }
    if (partialLength == manifest.sizeBytes) {
      try {
        final completedPath = await _finalizeDownload(manifest, files);
        return AppUpdateDownloadSnapshot(
          receivedBytes: manifest.sizeBytes,
          totalBytes: manifest.sizeBytes,
          completedPath: completedPath,
        );
      } on AppUpdateException {
        return AppUpdateDownloadSnapshot(
          receivedBytes: 0,
          totalBytes: manifest.sizeBytes,
        );
      }
    }
    return AppUpdateDownloadSnapshot(
      receivedBytes: partialLength,
      totalBytes: manifest.sizeBytes,
    );
  }

  Future<void> clearDownloads() async {
    final baseDirectory = await _directoryProvider();
    final directory = Directory(
      '${baseDirectory.path}${Platform.pathSeparator}app_updates',
    );
    if (!await directory.exists()) return;
    await _clearOldDownloads(directory);
  }

  Future<bool> canRequestPackageInstalls() =>
      _platform.canRequestPackageInstalls();

  Future<void> openInstallPermission() => _platform.openInstallPermission();

  Future<void> installApk(String path) => _platform.installApk(path);

  Future<_UpdateFiles> _filesFor(AppUpdateManifest manifest) async {
    final baseDirectory = await _directoryProvider();
    final directory = Directory(
      '${baseDirectory.path}${Platform.pathSeparator}app_updates',
    );
    await directory.create(recursive: true);
    final safeVersion = manifest.versionName.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    final digestPrefix = manifest.sha256.substring(0, 12);
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      'mesting-music-$safeVersion-${manifest.versionCode}-$digestPrefix.apk',
    );
    return _UpdateFiles(
      directory: directory,
      target: target,
      partial: File('${target.path}.partial'),
    );
  }

  Future<String> _finalizeDownload(
    AppUpdateManifest manifest,
    _UpdateFiles files,
  ) async {
    if (!await _matchesDigest(files.partial, manifest.sha256)) {
      await _deleteIfPresent(files.partial);
      throw const AppUpdateException('安装包校验失败，请重新下载', code: 'sha256');
    }
    await _deleteIfPresent(files.target);
    await files.partial.rename(files.target.path);
    return files.target.path;
  }

  Future<bool> _matchesDigest(File file, String expected) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString().toLowerCase() == expected;
  }

  bool _validContentRange(String? value, int start, int total) {
    if (value == null) return false;
    final match = RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(value.trim());
    if (match == null) return false;
    final actualStart = int.tryParse(match.group(1)!);
    final actualEnd = int.tryParse(match.group(2)!);
    final actualTotal = int.tryParse(match.group(3)!);
    return actualStart == start &&
        actualEnd != null &&
        actualEnd >= start &&
        actualEnd < total &&
        actualTotal == total;
  }

  bool _sameBytes(List<int> expected, List<int> actual, int length) {
    if (expected.length != length || actual.length < length) return false;
    for (var index = 0; index < length; index++) {
      if (expected[index] != actual[index]) return false;
    }
    return true;
  }

  void _throwIfCancelled(UpdateDownloadCancellationToken? token) {
    if (token?.isCancelled == true) {
      throw const AppUpdateException('下载已暂停', code: 'paused');
    }
  }

  Future<int> _safeLength(File file) async {
    try {
      return await file.exists() ? await file.length() : 0;
    } on FileSystemException {
      return 0;
    }
  }

  Future<void> _clearOldDownloads(
    Directory directory, {
    Set<String> keep = const {},
  }) async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list()) {
      if (entity is File &&
          !keep.contains(entity.path) &&
          entity.uri.pathSegments.last.startsWith('mesting-music-') &&
          (entity.path.endsWith('.apk') || entity.path.endsWith('.partial'))) {
        await _deleteIfPresent(entity);
      }
    }
  }

  Future<void> _deleteIfPresent(File file) async {
    if (await file.exists()) await file.delete();
  }
}

class _UpdateFiles {
  const _UpdateFiles({
    required this.directory,
    required this.target,
    required this.partial,
  });

  final Directory directory;
  final File target;
  final File partial;
}
