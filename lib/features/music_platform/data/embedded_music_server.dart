import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';

typedef _StartNative = Int32 Function(Int32, Pointer<Utf8>);
typedef _StartDart = int Function(int, Pointer<Utf8>);

/// Calls the upstream C ABI rather than JNI names tied to md3Music's package.
/// dlopen and server startup run off the UI isolate. Rust binds only loopback.
int _startNative(String directory) {
  final library = DynamicLibrary.open('libkugou_server.so');
  final start = library.lookupFunction<_StartNative, _StartDart>(
    'start_server',
  );
  final path = directory.toNativeUtf8();
  try {
    return start(0, path);
  } finally {
    calloc.free(path);
  }
}

abstract interface class MusicServer {
  Future<Uri> start();
}

/// Owns only the local transport, never Mesting authentication or audio output.
/// Concurrent callers share startup; failures release the future for retry.
class EmbeddedMusicServer implements MusicServer {
  Future<Uri>? _starting;

  @override
  Future<Uri> start() => _starting ??= _start().catchError((Object error) {
    _starting = null;
    throw error;
  });

  Future<Uri> _start() async {
    if (!Platform.isAndroid) {
      throw StateError('音乐平台本机服务目前仅在 Android 版中提供');
    }
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/music_platform/runtime');
    await directory.create(recursive: true);
    final port = await Isolate.run(() => _startNative(directory.path));
    if (port < 1 || port > 65535) throw StateError('音乐平台本机服务启动失败，请重试');
    // Startup is lazy: an unavailable platform must never block guest entry.
    for (var attempt = 0; attempt < 30; attempt++) {
      try {
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          port,
          timeout: const Duration(milliseconds: 200),
        );
        socket.destroy();
        return Uri(scheme: 'http', host: '127.0.0.1', port: port);
      } on SocketException {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    throw TimeoutException('音乐平台本机服务尚未就绪，请重试');
  }
}
