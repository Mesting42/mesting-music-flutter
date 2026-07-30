import 'package:flutter/services.dart';

import '../domain/lrc_parser.dart';
import '../domain/lyrics_document.dart';

class LyricsRepository {
  LyricsRepository({LrcParser parser = const LrcParser()}) : _parser = parser;

  final LrcParser _parser;
  final Map<String, LyricsDocument> _cache = {};

  Future<LyricsDocument> loadAsset(String assetPath) async {
    final cached = _cache[assetPath];
    if (cached != null) return cached;
    final source = await rootBundle.loadString(assetPath);
    final document = _parser.parse(source);
    _cache[assetPath] = document;
    return document;
  }
}
