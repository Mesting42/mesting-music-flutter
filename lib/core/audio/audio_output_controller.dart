import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AudioOutput {
  const AudioOutput({
    this.name = '本机扬声器',
    this.headphones = false,
    this.available = false,
  });
  final String name;
  final bool headphones, available;
  static AudioOutput fromMap(Map<Object?, Object?> value) => AudioOutput(
    name: (value['name'] as String?)?.trim().isNotEmpty == true
        ? value['name'] as String
        : '本机扬声器',
    headphones: value['kind'] == 'headphones',
    available: value['available'] == true,
  );
}

/// One lifecycle-scoped subscription, independent of playback position ticks.
/// Device names are native metadata; never infer an AirPods brand or codec.
class AudioOutputController extends Notifier<AudioOutput>
    with WidgetsBindingObserver {
  static const methods = MethodChannel('com.mesting.music/audio_output');
  static const events = EventChannel('com.mesting.music/audio_output_events');
  StreamSubscription<Object?>? _events;
  bool _disposed = false;
  @override
  AudioOutput build() {
    _disposed = false;
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _disposed = true;
      WidgetsBinding.instance.removeObserver(this);
      _events?.cancel();
    });
    unawaited(Future<void>.microtask(_attach));
    return const AudioOutput();
  }

  void _accept(Object? raw) {
    if (_disposed || raw is! Map) return;
    final next = AudioOutput.fromMap(raw.cast<Object?, Object?>());
    if (state.name != next.name ||
        state.headphones != next.headphones ||
        state.available != next.available) {
      state = next;
    }
  }

  Future<void> refresh() async {
    try {
      _accept(await methods.invokeMapMethod<Object?, Object?>('current'));
    } on MissingPluginException {
      /* Host rendering has no Android route service. */
    } on PlatformException {
      /* A later foreground refresh can recover. */
    }
  }

  Future<void> _attach() async {
    await refresh();
    if (_disposed || !state.available || _events != null) return;
    _events = events.receiveBroadcastStream().listen(
      _accept,
      onError: (Object _) {},
    );
  }

  Future<void> choose() async {
    if (!state.available) return;
    await methods.invokeMethod<bool>('choose');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_attach());
  }
}

final audioOutputProvider =
    NotifierProvider<AudioOutputController, AudioOutput>(
      AudioOutputController.new,
    );
