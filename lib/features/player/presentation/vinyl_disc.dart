import 'package:flutter/material.dart';

class VinylDisc extends StatefulWidget {
  const VinylDisc({required this.coverAsset, required this.playing, super.key});

  final String coverAsset;
  final bool playing;

  @override
  State<VinylDisc> createState() => _VinylDiscState();
}

class _VinylDiscState extends State<VinylDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    if (widget.playing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant VinylDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing == oldWidget.playing) return;
    if (widget.playing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  stops: [0, 0.23, 0.24, 0.34, 0.35, 1],
                  colors: [
                    Color(0xFF3C334D),
                    Color(0xFF191522),
                    Color(0xFF4B405F),
                    Color(0xFF17131E),
                    Color(0xFF2A2434),
                    Color(0xFF0D0B10),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55212B4D),
                    blurRadius: 54,
                    offset: Offset(0, 24),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(52),
                child: Hero(
                  tag: 'current-track-cover',
                  child: ClipOval(
                    child: Image.asset(widget.coverAsset, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          const FractionallySizedBox(
            widthFactor: 0.045,
            heightFactor: 0.045,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFFBF3),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 4,
            child: AnimatedRotation(
              turns: widget.playing ? 0.08 : -0.03,
              duration: const Duration(milliseconds: 480),
              alignment: const Alignment(0.8, -0.8),
              curve: Curves.easeOutBack,
              child: Container(
                width: 20,
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5C7B4),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF6D5A4B), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
