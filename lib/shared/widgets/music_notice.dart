import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

OverlayEntry? _activeMusicNotice;

// 64dp bottom navigation + 64dp mini player + 16dp visual gap.
const double musicNoticeBottomClearance = 144;

void showMusicNotice(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
}) {
  _activeMusicNotice?.remove();
  _activeMusicNotice = null;

  final overlay = Overlay.of(context, rootOverlay: true);
  final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) => _MusicNoticeOverlay(
      icon: icon,
      title: title,
      message: message,
      bottomInset: bottomInset,
      onDismissed: () {
        if (_activeMusicNotice != entry) return;
        entry.remove();
        _activeMusicNotice = null;
      },
    ),
  );
  _activeMusicNotice = entry;
  overlay.insert(entry);
}

class _MusicNoticeOverlay extends StatefulWidget {
  const _MusicNoticeOverlay({
    required this.icon,
    required this.title,
    required this.message,
    required this.bottomInset,
    required this.onDismissed,
  });

  final IconData icon;
  final String title;
  final String message;
  final double bottomInset;
  final VoidCallback onDismissed;

  @override
  State<_MusicNoticeOverlay> createState() => _MusicNoticeOverlayState();
}

class _MusicNoticeOverlayState extends State<_MusicNoticeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
          reverseDuration: const Duration(milliseconds: 180),
        )..addStatusListener((status) {
          if (status == AnimationStatus.dismissed) widget.onDismissed();
        });
    _controller.forward();
    _dismissTimer = Timer(
      const Duration(milliseconds: 1250),
      _controller.reverse,
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final success = widget.icon == Icons.check_rounded;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Positioned(
      left: 20,
      right: 20,
      bottom: widget.bottomInset + musicNoticeBottomClearance,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .24),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: .96, end: 1).animate(animation),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 42,
                        maxWidth: 360,
                      ),
                      padding: const EdgeInsets.fromLTRB(9, 7, 15, 7),
                      decoration: BoxDecoration(
                        color: const Color(0xE61A171E),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0x2EFFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3D000000),
                            blurRadius: 28,
                            offset: Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Color(0x1FFFFFFF),
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: success ? const Color(0xFF55A07D) : accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Flexible(
                            child: widget.message.trim().isEmpty
                                ? Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.none,
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      Text(
                                        widget.message,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xBFFFFFFF),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
