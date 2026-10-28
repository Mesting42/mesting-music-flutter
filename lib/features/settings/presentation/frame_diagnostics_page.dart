import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/performance/frame_timing_probe.dart';
import '../../../shared/widgets/beta_glass_controls.dart';
import '../../music_platform/presentation/platform_design.dart';

/// User-run performance evidence without connecting or reading their phone.
class FrameDiagnosticsPage extends StatefulWidget {
  const FrameDiagnosticsPage({super.key});
  @override
  State<FrameDiagnosticsPage> createState() => _FrameDiagnosticsPageState();
}

class _FrameDiagnosticsPageState extends State<FrameDiagnosticsPage> {
  bool _copied = false;
  @override
  Widget build(BuildContext context) => PlatformPageFrame(
    title: '流畅度诊断',
    child: AnimatedBuilder(
      animation: Listenable.merge([
        FrameTimingProbe.recording,
        FrameTimingProbe.draining,
      ]),
      builder: (context, _) {
        final recording = FrameTimingProbe.recording.value;
        final draining = FrameTimingProbe.draining.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 210),
          children: [
            Text(
              '当前显示刷新率：${View.of(context).display.refreshRate.toStringAsFixed(0)} Hz',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const Text(
              '开始采集后返回应用，切换页面、滚动并展开和收起底部播放胶囊，再回到这里停止并复制报告。每次最多采集 90 秒。',
            ),
            const SizedBox(height: 12),
            const Text(
              '报告包含应用版本、主题、显示尺寸、逐帧耗时、玻璃绘制计数及切换标记，不包含账号或歌曲信息。120 Hz 对应每帧约 8.33 毫秒。停止后会等待约 1 秒收齐末批数据。',
            ),
            const SizedBox(height: 26),
            BetaGlassButton(
              blue: !recording,
              onPressed: draining
                  ? null
                  : () async {
                      setState(() => _copied = false);
                      if (recording) {
                        await FrameTimingProbe.stopSession();
                      } else {
                        final info = await PackageInfo.fromPlatform();
                        if (!context.mounted) return;
                        final view = View.of(context);
                        FrameTimingProbe.beginSession(
                          view.display.refreshRate,
                          environment: {
                            'appVersion': info.version,
                            'buildNumber': info.buildNumber,
                            'theme': Theme.of(context).brightness.name,
                            'physicalWidth': view.physicalSize.width,
                            'physicalHeight': view.physicalSize.height,
                            'devicePixelRatio': view.devicePixelRatio,
                            // Capability, not an assertion of the active GPU backend.
                            'shaderFilterSupported':
                                ui.ImageFilter.isShaderFilterSupported,
                          },
                        );
                      }
                    },
              child: Text(
                draining
                    ? '正在收齐报告…'
                    : recording
                    ? '停止采集'
                    : '开始采集',
              ),
            ),
            const SizedBox(height: 14),
            BetaGlassButton(
              onPressed: recording || draining
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: jsonEncode(FrameTimingProbe.sessionReport()),
                        ),
                      );
                      if (mounted) setState(() => _copied = true);
                    },
              child: Text(_copied ? '报告已复制' : '复制诊断报告'),
            ),
            if (!recording)
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Text(
                  FrameTimingProbe.sessionReport()['summary']! as String,
                ),
              ),
          ],
        );
      },
    ),
  );
}
