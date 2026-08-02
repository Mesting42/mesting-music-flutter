import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/persistence/app_preferences.dart';
import 'data/app_update_platform.dart';
import 'data/app_update_repository.dart';
import 'domain/app_update_models.dart';

const _snoozedVersionPreference = 'app_update_snoozed_version';
const _snoozedUntilPreference = 'app_update_snoozed_until';

final appUpdateHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final appUpdatePlatformProvider = Provider<AppUpdatePlatform>(
  (ref) => AppUpdatePlatform(),
);

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>((ref) {
  return AppUpdateRepository(
    client: ref.watch(appUpdateHttpClientProvider),
    platform: ref.watch(appUpdatePlatformProvider),
  );
});

final appVersionProvider = FutureProvider<AppVersionInfo>((ref) {
  return ref.watch(appUpdateRepositoryProvider).currentVersion();
});

final autoAppUpdateChecksEnabledProvider = Provider<bool>((ref) {
  return const bool.fromEnvironment(
    'ENABLE_APP_UPDATE_CHECKS',
    defaultValue: kReleaseMode,
  );
});

enum AppUpdatePhase {
  idle,
  checking,
  upToDate,
  available,
  downloading,
  paused,
  permissionRequired,
  readyToInstall,
  launchingInstaller,
  installLaunched,
  failed,
}

@immutable
class AppUpdateState {
  const AppUpdateState({
    this.phase = AppUpdatePhase.idle,
    this.currentVersion,
    this.manifest,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.downloadedPath,
    this.errorMessage,
  });

  final AppUpdatePhase phase;
  final AppVersionInfo? currentVersion;
  final AppUpdateManifest? manifest;
  final int receivedBytes;
  final int totalBytes;
  final String? downloadedPath;
  final String? errorMessage;

  double? get progress {
    if (totalBytes <= 0) return null;
    return (receivedBytes / totalBytes).clamp(0, 1);
  }

  bool get busy =>
      phase == AppUpdatePhase.checking ||
      phase == AppUpdatePhase.downloading ||
      phase == AppUpdatePhase.launchingInstaller;

  AppUpdateState copyWith({
    AppUpdatePhase? phase,
    Object? currentVersion = _unset,
    Object? manifest = _unset,
    int? receivedBytes,
    int? totalBytes,
    Object? downloadedPath = _unset,
    Object? errorMessage = _unset,
  }) {
    return AppUpdateState(
      phase: phase ?? this.phase,
      currentVersion: identical(currentVersion, _unset)
          ? this.currentVersion
          : currentVersion as AppVersionInfo?,
      manifest: identical(manifest, _unset)
          ? this.manifest
          : manifest as AppUpdateManifest?,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedPath: identical(downloadedPath, _unset)
          ? this.downloadedPath
          : downloadedPath as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _unset = Object();

final appUpdateControllerProvider =
    NotifierProvider<AppUpdateController, AppUpdateState>(
      AppUpdateController.new,
    );

class AppUpdateController extends Notifier<AppUpdateState> {
  AppUpdateRepository get _repository => ref.read(appUpdateRepositoryProvider);
  UpdateDownloadCancellationToken? _downloadCancellation;
  Future<void>? _activeDownload;

  @override
  AppUpdateState build() {
    ref.onDispose(() {
      final cancellation = _downloadCancellation;
      if (cancellation != null) unawaited(cancellation.cancel());
    });
    return const AppUpdateState();
  }

  Future<AppUpdateCheckResult?> check({bool manual = false}) async {
    if (state.phase == AppUpdatePhase.checking) return null;
    state = state.copyWith(phase: AppUpdatePhase.checking, errorMessage: null);
    try {
      final result = await _repository.check();
      if (!result.updateAvailable) {
        await _repository.clearDownloads();
      }
      final download = result.updateAvailable
          ? await _repository.inspectDownload(result.manifest)
          : null;
      state = AppUpdateState(
        phase: !result.updateAvailable
            ? AppUpdatePhase.upToDate
            : download!.isComplete
            ? AppUpdatePhase.readyToInstall
            : download.receivedBytes > 0
            ? AppUpdatePhase.paused
            : AppUpdatePhase.available,
        currentVersion: result.currentVersion,
        manifest: result.manifest,
        receivedBytes: download?.receivedBytes ?? 0,
        totalBytes: download?.totalBytes ?? 0,
        downloadedPath: download?.completedPath,
      );
      ref.invalidate(appVersionProvider);
      if (!result.updateAvailable) return result;
      if (!manual && !result.mandatory && _isSnoozed(result.manifest)) {
        return null;
      }
      return result;
    } on AppUpdateException catch (error) {
      state = state.copyWith(
        phase: AppUpdatePhase.failed,
        errorMessage: error.message,
      );
      return null;
    }
  }

  Future<void> downloadAndInstall() async {
    final previousDownload = _activeDownload;
    if (previousDownload != null) {
      await previousDownload;
    }
    final manifest = state.manifest;
    if (manifest == null || state.busy) return;
    final task = _runDownload(manifest);
    _activeDownload = task;
    try {
      await task;
    } finally {
      if (identical(_activeDownload, task)) {
        _activeDownload = null;
      }
    }
  }

  Future<void> _runDownload(AppUpdateManifest manifest) async {
    final cancellation = UpdateDownloadCancellationToken();
    _downloadCancellation = cancellation;
    final existing = await _repository.inspectDownload(manifest);
    if (existing.completedPath case final completedPath?) {
      state = state.copyWith(
        phase: AppUpdatePhase.readyToInstall,
        receivedBytes: manifest.sizeBytes,
        totalBytes: manifest.sizeBytes,
        downloadedPath: completedPath,
        errorMessage: null,
      );
      await continueInstall();
      return;
    }
    state = state.copyWith(
      phase: AppUpdatePhase.downloading,
      receivedBytes: existing.receivedBytes,
      totalBytes: manifest.sizeBytes,
      downloadedPath: null,
      errorMessage: null,
    );
    try {
      final path = await _repository.download(
        manifest,
        cancellationToken: cancellation,
        onProgress: (receivedBytes, totalBytes) {
          if (state.phase != AppUpdatePhase.downloading) return;
          state = state.copyWith(
            receivedBytes: receivedBytes,
            totalBytes: totalBytes > 0 ? totalBytes : manifest.sizeBytes,
          );
        },
      );
      state = state.copyWith(
        phase: AppUpdatePhase.readyToInstall,
        receivedBytes: manifest.sizeBytes,
        totalBytes: manifest.sizeBytes,
        downloadedPath: path,
      );
      await continueInstall();
    } on AppUpdateException catch (error) {
      final persisted = await _repository.inspectDownload(manifest);
      if (error.code == 'paused') {
        state = state.copyWith(
          phase: persisted.isComplete
              ? AppUpdatePhase.readyToInstall
              : AppUpdatePhase.paused,
          receivedBytes: persisted.receivedBytes,
          totalBytes: manifest.sizeBytes,
          downloadedPath: persisted.completedPath,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          phase: persisted.isComplete
              ? AppUpdatePhase.readyToInstall
              : AppUpdatePhase.failed,
          receivedBytes: persisted.receivedBytes,
          totalBytes: manifest.sizeBytes,
          downloadedPath: persisted.completedPath,
          errorMessage: persisted.isComplete ? null : error.message,
        );
      }
    } finally {
      if (identical(_downloadCancellation, cancellation)) {
        _downloadCancellation = null;
      }
    }
  }

  Future<void> pauseDownload() async {
    if (state.phase != AppUpdatePhase.downloading) return;
    state = state.copyWith(phase: AppUpdatePhase.paused, errorMessage: null);
    await _downloadCancellation?.cancel();
    final activeDownload = _activeDownload;
    if (activeDownload != null) {
      await activeDownload;
    }
  }

  Future<void> continueInstall() async {
    final path = state.downloadedPath;
    if (path == null || state.phase == AppUpdatePhase.launchingInstaller) {
      return;
    }
    try {
      if (!await _repository.canRequestPackageInstalls()) {
        state = state.copyWith(phase: AppUpdatePhase.permissionRequired);
        return;
      }
      state = state.copyWith(
        phase: AppUpdatePhase.launchingInstaller,
        errorMessage: null,
      );
      await _repository.installApk(path);
      state = state.copyWith(phase: AppUpdatePhase.installLaunched);
    } on PlatformException catch (error) {
      state = state.copyWith(
        phase: AppUpdatePhase.failed,
        errorMessage: _platformErrorMessage(error.code),
      );
    } on Object {
      state = state.copyWith(
        phase: AppUpdatePhase.failed,
        errorMessage: '无法打开系统安装页面，请稍后重试',
      );
    }
  }

  Future<void> openInstallPermission() async {
    try {
      await _repository.openInstallPermission();
    } on Object {
      state = state.copyWith(
        phase: AppUpdatePhase.failed,
        errorMessage: '无法打开安装权限设置',
      );
    }
  }

  Future<void> snooze() async {
    final manifest = state.manifest;
    if (manifest == null) return;
    final preferences = ref.read(sharedPreferencesProvider);
    await preferences.setInt(_snoozedVersionPreference, manifest.versionCode);
    await preferences.setInt(
      _snoozedUntilPreference,
      DateTime.now().add(const Duration(hours: 12)).millisecondsSinceEpoch,
    );
  }

  bool _isSnoozed(AppUpdateManifest manifest) {
    final preferences = ref.read(sharedPreferencesProvider);
    return preferences.getInt(_snoozedVersionPreference) ==
            manifest.versionCode &&
        (preferences.getInt(_snoozedUntilPreference) ?? 0) >
            DateTime.now().millisecondsSinceEpoch;
  }

  String _platformErrorMessage(String code) {
    return switch (code) {
      'apk_package_mismatch' => '安装包与当前应用不匹配',
      'apk_version_not_newer' => '安装包版本不高于当前版本',
      'apk_signature_mismatch' => '安装包签名校验失败，已阻止安装',
      'invalid_apk' => '安装包无效或已经损坏',
      'invalid_path' => '安装包路径不安全，已阻止安装',
      'installer_unavailable' => '系统安装程序不可用',
      _ => '无法打开系统安装页面，请稍后重试',
    };
  }
}
