import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'netease_api.dart';
import 'netease_session.dart';

final neteaseSessionStoreProvider = Provider<NeteaseSessionStore>(
  (ref) => const SecureNeteaseSessionStore(),
);
final neteaseApiProvider = Provider<NeteaseApi>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return NeteaseApi(client);
});
