import 'dart:convert';
import 'package:flutter/services.dart';

class MusicRegion {
  const MusicRegion(this.name, this.code, this.cities);
  final String name, code;
  final List<({String name, String code})> cities;
}

/// Offline province/city names are sent to Kugou, never guessed numeric IDs.
/// Municipalities use their own city name rather than a district as a city.
Future<List<MusicRegion>> loadMusicRegions() async {
  final rows =
      jsonDecode(await rootBundle.loadString('assets/data/music-regions.json'))
          as List;
  return rows
      .map((raw) {
        final row = raw as Map;
        final code = '${row['code']}';
        final name = '${row['name']}';
        final municipal = const {'11', '12', '31', '50'}.contains(code);
        return MusicRegion(
          name,
          code,
          municipal
              ? [(name: name, code: '${code}01')]
              : (row['children'] as List)
                    .map(
                      (city) =>
                          (name: '${city['name']}', code: '${city['code']}'),
                    )
                    .toList(growable: false),
        );
      })
      .toList(growable: false);
}
