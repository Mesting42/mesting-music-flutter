import 'package:flutter/scheduler.dart';

/// Anonymous CPU-side paint counters. These are NOT GPU timings or presented
/// frames. Disabled by default; the app explicitly starts/stops a bounded run.
/// Keeping this in the renderer package avoids a dependency on the app layer.
enum GlassRenderMetric {
  glassPaints,
  blurPasses,
  sharedBlurPasses,
  shaderPasses,
  matteRebuilds,
  matteCacheHits,
  mattePixels,
  shadowLivePasses,
  shadowBakes,
  shadowCacheHits,
  captures,
  capturePixels,
}

/// No song/account/device identifiers or filesystem information are collected.
class GlassRenderDiagnostics {
  GlassRenderDiagnostics._();

  static bool _enabled = false;
  static const _limit = 14000;
  static final Map<int, Map<String, int>> _frames = {};
  static int? _afterVsyncUs;

  /// Starts an empty, opt-in capture. No frame callbacks/tickers are installed.
  static void begin({int? afterVsyncUs}) {
    _frames.clear();
    _afterVsyncUs = afterVsyncUs;
    _enabled = true;
  }

  /// Stops allocations immediately, retaining only the bounded report.
  static void stop() => _enabled = false;

  /// Counts actual paint work at the raw engine vsync that produced it. Retained
  /// layers may be composited without painting, so absent rows mean no observed
  /// CPU paint work, not zero GPU work.
  static void count(GlassRenderMetric metric, {int amount = 1}) {
    if (!_enabled) return;
    final vsync =
        SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds;
    if (_afterVsyncUs != null && vsync <= _afterVsyncUs!) return;
    if (_frames.length >= _limit && !_frames.containsKey(vsync)) return;
    final row = _frames.putIfAbsent(vsync, () => {});
    row.update(metric.name, (old) => old + amount, ifAbsent: () => amount);
  }

  /// Independent copies so exporting cannot mutate the renderer's state.
  static List<Map<String, Object>> report() => [
        for (final entry in _frames.entries)
          {'vsyncUs': entry.key, ...entry.value},
      ];
}
