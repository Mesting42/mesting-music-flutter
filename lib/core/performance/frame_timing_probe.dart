import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

const bool frameTimingProbeEnabled = bool.fromEnvironment(
  'MESTING_FRAME_TIMING_PROBE',
);

class FrameTimingProbe {
  FrameTimingProbe._();

  static const _sampleSize = 120;
  static final List<FrameTiming> _samples = <FrameTiming>[];
  static bool _started = false;

  static void start() {
    if (!frameTimingProbeEnabled || _started) return;
    _started = true;
    SchedulerBinding.instance.addTimingsCallback(_collect);
  }

  static void _collect(List<FrameTiming> timings) {
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
