import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/platform_mv_repository.dart';
import 'music_platform_providers.dart';

final platformMvRepositoryProvider = Provider<PlatformMvRepository>(
  (ref) => PlatformMvRepository(ref.watch(musicPlatformApiProvider)),
);
