import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/playback_providers.dart';
import '../../../core/persistence/app_preferences.dart';
import '../../../core/persistence/playback_persistence_controller.dart';
import '../../library/library_providers.dart';
import '../music_platform_providers.dart';
import 'listening_sync_coordinator.dart';
import 'listening_sync_models.dart';
import 'listening_sync_repository.dart';
import 'listening_sync_store.dart';

final platformListeningSyncEnabledProvider =
    NotifierProvider<ListeningSyncEnabled, bool>(ListeningSyncEnabled.new);

class ListeningSyncEnabled extends Notifier<bool> {
  static const preferenceKey = 'kugou_listening_cloud_sync_v1';
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(preferenceKey) ?? true;

  Future<void> setEnabled(bool enabled) async {
    // Persist before publishing the toggle, so a storage failure is visible to
    // the settings caller and cannot silently change the next launch's policy.
    final saved = await ref
        .read(sharedPreferencesProvider)
        .setBool(preferenceKey, enabled);
    if (!saved) throw StateError('同步设置暂未保存，请重试');
    state = enabled;
  }
}

final platformListeningSyncStoreProvider = Provider<ListeningSyncStore>(
  (ref) => ListeningSyncStore(ref.watch(appDatabaseProvider)),
);

/// Watch once from the Beta application root. Rebuilds/route changes do not
/// create more subscriptions; account and toggle listeners drive activation.
final platformListeningSyncProvider = Provider<ListeningSyncCoordinator>((ref) {
  final api = ref.watch(musicPlatformApiProvider);
  final coordinator = ListeningSyncCoordinator(
    feed: HandlerListeningAudioFeed(ref.watch(audioHandlerProvider)),
    store: ref.watch(platformListeningSyncStoreProvider),
    gateway: KugouListeningRepository(api),
    currentIdentity: () => api.session,
    prepareOwner: ref
        .watch(playbackPersistenceControllerProvider)
        .activateOwner,
  );
  void activate() => unawaited(
    coordinator.activate(
      ref.read(platformAccountProvider).value,
      enabled: ref.read(platformListeningSyncEnabledProvider),
    ),
  );
  ref.listen(platformAccountProvider, (previous, next) {
    final before = previous?.value;
    final after = next.value;
    // Profile metadata changes keep the same authentication epoch. They
    // must not manufacture another play instance or split a listening span.
    if (previous != null &&
        before?.userId == after?.userId &&
        before?.token == after?.token) {
      return;
    }
    activate();
  }, fireImmediately: true);
  ref.listen(platformListeningSyncEnabledProvider, (_, _) => activate());
  ref.onDispose(() => unawaited(coordinator.dispose()));
  return coordinator;
});

final platformListeningSyncSummaryProvider =
    StreamProvider<ListeningSyncSummary>((ref) {
      final session = ref.watch(platformAccountProvider).value;
      if (session == null) return Stream.value(ListeningSyncSummary(const []));
      return ref
          .watch(platformListeningSyncStoreProvider)
          .watchSummary('kugou:${session.userId}');
    });
