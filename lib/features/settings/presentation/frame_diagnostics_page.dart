import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    child: ValueListenableBuilder<bool>(
      valueListenable: FrameTimingProbe.recording,
      builder: (context, recording, _) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 210),
        children: [
          Text(
            '当前显示刷新率：${View.of(context).display.refreshRate.toStringAsFixed(0)} Hz',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const Text('开始采集后返回应用，切换页面、滚动并展开和收起底部播放胶囊，再回到这里停止并复制报告。每次最多采集 90 秒。'),
          const SizedBox(height: 12),
          const Text(
            '报告包含逐帧构建、光栅耗时及切换标记，可用于定位卡顿；不包含账号或歌曲信息。120 Hz 对应每帧约 8.33 毫秒。',
          ),
          const SizedBox(height: 26),
          BetaGlassButton(
            blue: !recording,
            onPressed: () {
              setState(() => _copied = false);
              if (recording) {
                FrameTimingProbe.stopSession();
              } else {
                FrameTimingProbe.beginSession(
                  View.of(context).display.refreshRate,
                );
              }
            },
            child: Text(recording ? '停止采集' : '开始采集'),
          ),
          const SizedBox(height: 14),
          BetaGlassButton(
            onPressed: recording
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
      ),
    ),
  );
}
