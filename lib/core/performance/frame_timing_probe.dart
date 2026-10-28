import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:ui' show FramePhase;

const bool frameTimingProbeEnabled = bool.fromEnvironment(
  'MESTING_FRAME_TIMING_PROBE',
);

class FrameTimingProbe {
  FrameTimingProbe._();

  static const _sampleSize = 120;
  static final List<FrameTiming> _samples = <FrameTiming>[];
  static bool _started = false;
  static final recording = ValueNotifier(false);
  static final List<FrameTiming> _session = [];
  static final List<Map<String, Object>> _transitions = [];
  static Timer? _deadline;
  static double _displayHz = 0;
  static final _elapsed = Stopwatch();

  /// Opt-in on-device capture. It records timing categories only: no songs,
  /// account IDs, credentials, network responses or filesystem paths.
  static void beginSession(double displayHz) {
    _session.clear();
    _transitions.clear();
    _displayHz = displayHz;
    _elapsed
      ..reset()
      ..start();
    _listen();
    recording.value = true;
    _deadline?.cancel();
    _deadline = Timer(const Duration(seconds: 90), stopSession);
  }

  static void markTransition(String label) {
    if (!recording.value || _transitions.length >= 250) return;
    _transitions.add({
      'event': label,
      'elapsedMs': _elapsed.elapsedMilliseconds,
    });
  }

  static void stopSession() {
    _deadline?.cancel();
    _deadline = null;
    _elapsed.stop();
    recording.value = false;
    if (_started && !frameTimingProbeEnabled) {
      SchedulerBinding.instance.removeTimingsCallback(_collect);
      _started = false;
    }
  }

  static Map<String, Object> sessionReport() => {
    'schema': 1,
    'displayHz': _displayHz,
    'elapsedMs': _elapsed.elapsedMilliseconds,
    'summary': frameTimingSummary(_session),
    'events': List.of(_transitions),
    'samples': [
      for (final timing in _session)
        {
          'vsyncUs': timing.timestampInMicroseconds(FramePhase.vsyncStart),
          'buildUs': timing.buildDuration.inMicroseconds,
          'rasterUs': timing.rasterDuration.inMicroseconds,
          'totalUs': timing.totalSpan.inMicroseconds,
        },
    ],
  };

  static void _listen() {
    if (_started) return;
    _started = true;
    SchedulerBinding.instance.addTimingsCallback(_collect);
  }

  static void start() {
    if (frameTimingProbeEnabled) _listen();
  }

  static void _collect(List<FrameTiming> timings) {
    if (recording.value) {
      // Bounded even on 144 Hz displays. Capture preserves real build/raster
      // durations; a widget-test pump count is never reported as device FPS.
      _session.addAll(timings.take((14000 - _session.length).clamp(0, 14000)));
    }
    if (!frameTimingProbeEnabled) return;
    _samples.addAll(timings);
    while (_samples.length >= _sampleSize) {
      final sample = _samples.sublist(0, _sampleSize);
      _samples.removeRange(0, _sampleSize);
      debugPrint('MESTING_FRAME_TIMING ${frameTimingSummary(sample)}');
    }
  }
}

String frameTimingSummary(List<FrameTiming> timings) {
  final builds =
      timings
          .map((timing) => timing.buildDuration.inMicroseconds)
          .toList(growable: false)
        ..sort();
  final rasters =
      timings
          .map((timing) => timing.rasterDuration.inMicroseconds)
          .toList(growable: false)
        ..sort();
  const highRefreshBudgetMicros = 8333;
  const standardRefreshBudgetMicros = 16667;
  final rasterOverHighRefresh = rasters
      .where((duration) => duration > highRefreshBudgetMicros)
      .length;
  final rasterOverStandardRefresh = rasters
      .where((duration) => duration > standardRefreshBudgetMicros)
      .length;

  return <String>[
    'frames=${timings.length}',
    'build_p50_ms=${_percentileMillis(builds, .50)}',
    'build_p90_ms=${_percentileMillis(builds, .90)}',
    'build_p99_ms=${_percentileMillis(builds, .99)}',
    'build_over_8_33=${builds.where((duration) => duration > highRefreshBudgetMicros).length}',
    'raster_p50_ms=${_percentileMillis(rasters, .50)}',
    'raster_p90_ms=${_percentileMillis(rasters, .90)}',
    'raster_p99_ms=${_percentileMillis(rasters, .99)}',
    'raster_over_8_33=$rasterOverHighRefresh',
    'raster_over_16_67=$rasterOverStandardRefresh',
  ].join(' ');
}

String _percentileMillis(List<int> sortedMicros, double percentile) {
  if (sortedMicros.isEmpty) return '0.00';
  final index = ((sortedMicros.length - 1) * percentile).floor();
  return (sortedMicros[index] / 1000).toStringAsFixed(2);
}
