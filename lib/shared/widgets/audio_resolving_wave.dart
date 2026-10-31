import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../features/themes/beta_appearance.dart';

/// Parsing has no measurable byte progress. This small authored waveform keeps
/// that state distinct from transfer progress, and honors reduced motion.
class AudioResolvingWave extends StatefulWidget {
  const AudioResolvingWave({super.key});
  @override
  State<AudioResolvingWave> createState() => _AudioResolvingWaveState();
}

class _AudioResolvingWaveState extends State<AudioResolvingWave>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
    } else {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: '正在解析音源',
    child: Row(
      children: [
        AnimatedBuilder(
          animation: _motion,
          builder: (context, _) => SizedBox(
            width: 42,
            height: 22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  Container(
                    width: 3,
                    height:
                        5 +
                        16 *
                            (.5 +
                                .5 *
                                    math.sin(
                                      _motion.value * math.pi * 2 + i * .8,
                                    )),
                    decoration: BoxDecoration(
                      color: BetaAppearance.accent(
                        Theme.of(context).brightness,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Flexible(child: Text('正在解析音源')),
      ],
    ),
  );
}
