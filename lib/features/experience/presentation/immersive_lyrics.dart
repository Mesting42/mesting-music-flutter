import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/playback_providers.dart';
import '../../lyrics/lyrics_providers.dart';
import '../../lyrics/domain/lyrics_document.dart';

/// Variable-height lines keep long lyrics and accessibility text sizes intact.
/// The measured offsets use the same text style as the rendered paragraphs.
class ImmersiveLyrics extends ConsumerStatefulWidget {
  const ImmersiveLyrics({super.key});
  @override
  ConsumerState<ImmersiveLyrics> createState() => _ImmersiveLyricsState();
}

class _ImmersiveLyricsState extends ConsumerState<ImmersiveLyrics> {
  final _scroll = ScrollController();
  int _active = -2;
  String _track = '';
  LyricsDocument? _measured;
  double _measuredWidth = 0;
  TextScaler? _measuredScaler;
  final _heights = <double>[];
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    if (_track != track.id) {
      _track = track.id;
      _active = -2;
    }
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    return ref
        .watch(lyricsProvider(track.resolvedLyricsAsset))
        .when(
          loading: () => const Center(
            child: Text('正在寻找歌词…', style: TextStyle(color: Colors.white70)),
          ),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(lyricsProvider(track.resolvedLyricsAsset)),
              child: const Text(
                '歌词暂时无法读取，点此重试',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          data: (document) {
            if (document.lines.isEmpty) {
              return const Center(
                child: Text(
                  '这首歌暂时没有歌词',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            final active = document.activeIndexAt(position);
            return LayoutBuilder(
              builder: (context, constraints) {
                final style = Theme.of(context).textTheme.headlineLarge!
                    .copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.45,
                      letterSpacing: -.5,
                    );
                final textWidth = (constraints.maxWidth - 48).clamp(
                  1.0,
                  double.infinity,
                );
                final scaler = MediaQuery.textScalerOf(context);
                // Position ticks only update the active line; measuring every
                // paragraph at audio frequency wastes frames on long songs.
                if (!identical(_measured, document) ||
                    _measuredWidth != textWidth ||
                    _measuredScaler != scaler) {
                  _measured = document;
                  _measuredWidth = textWidth;
                  _measuredScaler = scaler;
                  _heights.clear();
                  _active = -2;
                  for (final line in document.lines) {
                    final painter = TextPainter(
                      text: TextSpan(
                        text: line.text.isEmpty ? ' ' : line.text,
                        style: style,
                      ),
                      textDirection: TextDirection.ltr,
                      textScaler: scaler,
                    )..layout(maxWidth: textWidth);
                    _heights.add(painter.height + 24);
                    painter.dispose();
                  }
                }
                if (_active != active) {
                  _active = active;
                  final target = _heights
                      .take(active.clamp(0, _heights.length))
                      .fold(0.0, (a, b) => a + b);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted || !_scroll.hasClients) return;
                    _scroll.animateTo(
                      target.clamp(0.0, _scroll.position.maxScrollExtent),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 460),
                      curve: Curves.easeOutCubic,
                    );
                  });
                }
                return ListView.builder(
                  key: ValueKey(track.id),
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    constraints.maxHeight * .2,
                    24,
                    constraints.maxHeight * .7,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: document.lines.length,
                  itemBuilder: (context, index) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: document.isSynced
                        ? () => ref
                              .read(audioHandlerProvider)
                              .seek(document.lines[index].time)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 260),
                        style: style.copyWith(
                          color: index == active
                              ? Colors.white
                              : const Color(0xA6FFFFFF),
                        ),
                        child: Text(document.lines[index].text),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
  }
}
