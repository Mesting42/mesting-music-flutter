import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MediaVolumeState {
  const MediaVolumeState({this.value = .5, this.available = false});
  final double value;
  final bool available;
}

/// Controls Android STREAM_MUSIC, never a second AudioPlayer's gain. Native
/// volume events include hardware-key changes; foreground refresh covers events
/// missed while the activity was suspended. Unsupported hosts stay disabled.
class MediaVolumeController extends Notifier<MediaVolumeState>
    with WidgetsBindingObserver {
  static const methods = MethodChannel('com.mesting.music/media_volume');
  static const events = EventChannel('com.mesting.music/media_volume_events');
  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  @override
  MediaVolumeState build() {
    _disposed = false;
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _disposed = true;
      WidgetsBinding.instance.removeObserver(this);
      _subscription?.cancel();
    });
    unawaited(Future<void>.microtask(_attach));
    return const MediaVolumeState();
  }

  Future<void> _attach() async {
    // Probe the method channel before opening events. EventChannel reports a
    // missing host plugin globally even with an onError stream listener.
    try {
      final value = await methods.invokeMethod<double>('getVolume');
      if (_disposed || value == null) return;
      _accept(value);
      _subscription = events.receiveBroadcastStream().listen(
        _accept,
        onError: (Object _) {},
      );
    } on MissingPluginException {
      // Unsupported desktop/test hosts keep a truthful disabled volume rail.
    } on PlatformException {
      // Foreground refresh can recover a temporarily unavailable audio service.
    }
  }

  void _accept(Object? value) {
    if (!_disposed && value is num) {
      state = MediaVolumeState(
        value: value.toDouble().clamp(0, 1),
        available: true,
      );
    }
  }

  Future<void> refresh() async {
    try {
      _accept(await methods.invokeMethod<double>('getVolume'));
    } on MissingPluginException {
      // Widget tests and desktop builds have no Android system-volume bridge.
    } on PlatformException {
      // A transient system service failure must not interrupt playback.
    }
  }

  Future<void> setVolume(double value) async {
    if (!state.available) return;
    try {
      _accept(
        await methods.invokeMethod<double>('setVolume', {
          'value': value.clamp(0, 1),
        }),
      );
    } on PlatformException {
      await refresh();
    } on MissingPluginException {
      // An engine may detach while the player route is closing.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }
}

final mediaVolumeProvider =
    NotifierProvider<MediaVolumeController, MediaVolumeState>(
      MediaVolumeController.new,
    );
