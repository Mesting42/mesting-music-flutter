import 'lyrics_document.dart';

class LrcParser {
  const LrcParser();

  static final RegExp _timestampPattern = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[\.:](\d{1,3}))?\]',
  );
  static final RegExp _offsetPattern = RegExp(
    r'^\[offset:([+-]?\d+)\]$',
    caseSensitive: false,
  );
  static final RegExp _metadataPattern = RegExp(
    r'^\[(ar|al|ti|by|re|ve):.*\]$',
    caseSensitive: false,
  );

  LyricsDocument parse(String source) {
    final normalized = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rawLines = normalized.split('\n');
    var offsetMilliseconds = 0;

    for (final rawLine in rawLines) {
      final offsetMatch = _offsetPattern.firstMatch(rawLine.trim());
      if (offsetMatch != null) {
        offsetMilliseconds = int.tryParse(offsetMatch.group(1) ?? '') ?? 0;
      }
    }

    final timedLines = <LyricsLine>[];
    final plainLines = <String>[];

    for (final rawLine in rawLines) {
      final line = rawLine.trim();
      if (line.isEmpty ||
          _offsetPattern.hasMatch(line) ||
          _metadataPattern.hasMatch(line)) {
        continue;
      }

      final matches = _timestampPattern.allMatches(line).toList();
      if (matches.isEmpty) {
        plainLines.add(line);
        continue;
      }

      final text = line.substring(matches.last.end).trim();
      if (text.isEmpty) continue;

      for (final match in matches) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final fraction = match.group(3) ?? '';
        final fractionMilliseconds = switch (fraction.length) {
          0 => 0,
          1 => int.parse(fraction) * 100,
          2 => int.parse(fraction) * 10,
          _ => int.parse(fraction.substring(0, 3)),
        };
        final totalMilliseconds =
            (minutes * 60 + seconds) * 1000 +
            fractionMilliseconds +
            offsetMilliseconds;
        timedLines.add(
          LyricsLine(
            time: Duration(milliseconds: totalMilliseconds.clamp(0, 1 << 31)),
            text: text,
          ),
        );
      }
    }

    if (timedLines.isNotEmpty) {
      timedLines.sort((left, right) => left.time.compareTo(right.time));
      return LyricsDocument(lines: timedLines, isSynced: true);
    }

    return LyricsDocument(
      lines: [
        for (final text in plainLines)
          LyricsLine(time: Duration.zero, text: text),
      ],
      isSynced: false,
    );
  }
}
