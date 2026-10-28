import '../domain/platform_session.dart';
import 'listening_sync_models.dart';
import 'listening_sync_repository.dart';
import 'listening_sync_store.dart';

/// One account's non-blocking journal drain. Playback and measurement never
/// await a network request. Ambiguous writes only receive read-back attempts.
class ListeningSyncWorker {
  ListeningSyncWorker({
    required this.store,
    required this.gateway,
    required this.identity,
    required this.currentIdentity,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;
  final ListeningSyncStore store;
  final ListeningPlatformGateway gateway;
  final PlatformSession identity;
  final PlatformSession? Function() currentIdentity;
  final DateTime Function() now;
  final Set<String> _liveSegments = {};
  bool _disposed = false, _flushing = false, _flushAgain = false;
  String get owner => 'kugou:${identity.userId}';
  bool get current =>
      !_disposed &&
      currentIdentity()?.userId == identity.userId &&
      currentIdentity()?.token == identity.token;

  void registerLiveSegment(String id) => _liveSegments.add(id);
  void dispose() => _disposed = true;

  Future<void> verifyPending() async {
    if (!current || _flushing) return;
    _flushing = true;
    try {
      await _attempt(() => _history(allowWrites: false));
      if (current) await _attempt(() => _grade(allowWrites: false));
    } on Object {
      // Keep the last confirmed journal state if official read-back fails.
    } finally {
      _flushing = false;
    }
  }

  Future<void> _attempt(Future<void> Function() operation) async {
    try {
      await operation();
    } on Object {
      // Each independent upstream chain keeps its own journal status. An
      // unavailable history read must not block a valid duration read/write.
    }
  }

  Future<void> flush() async {
    if (!current) return;
    if (_flushing) {
      _flushAgain = true;
      return;
    }
    _flushing = true;
    try {
      // At most one coalesced follow-up. New audio edges cannot create a busy
      // retry loop against an unavailable platform.
      for (var pass = 0; pass < 2; pass++) {
        _flushAgain = false;
        await gateway.prepare(identity);
        if (!current) return;
        await _attempt(_events);
        if (!current) return;
        await _attempt(() => _history());
        if (!current) return;
        await _attempt(() => _grade());
        if (!_flushAgain || !current) break;
      }
    } on Object {
      // Transport failures leave durable state as queued or uncertain.
      // Raw errors may contain credentials, so no exception is logged here.
    } finally {
      _flushing = false;
    }
  }

  Future<ListeningSyncEntry?> _resolve(ListeningSyncEntry row) async {
    if (RegExp(r'^[1-9]\d*$').hasMatch(row.text('recordingId'))) return row;
    final id = await gateway.resolveRecording(identity, row.text('trackId'));
    if (!current) return null;
    if (id.isEmpty) {
      await store.change(
        row,
        ListeningSyncState.rejected,
        now(),
        payload: {...row.payload, 'result': 'recording_identity_unavailable'},
      );
      return null;
    }
    final payload = {...row.payload, 'recordingId': id};
    await store.change(row, row.state, now(), payload: payload);
    return ListeningSyncEntry(
      ownerId: row.ownerId,
      id: row.id,
      kind: row.kind,
      payload: payload,
      state: row.state,
      createdAt: row.createdAt,
      updatedAt: now(),
    );
  }

  Future<void> _events() async {
    final rows =
        (await store.entries(
              owner,
              kinds: {'cscc'},
              states: {ListeningSyncState.queued},
            ))
            .where(
              (r) => r.kind == 'cscc' && r.state == ListeningSyncState.queued,
            )
            .toList();
    for (final original in rows) {
      if (!current) return;
      final segmentId = original.text('segmentId');
      if (!_liveSegments.contains(segmentId) ||
          now().difference(original.createdAt) > const Duration(minutes: 2)) {
        await store.change(
          original,
          ListeningSyncState.interrupted,
          now(),
          payload: {...original.payload, 'result': 'stale_event_not_replayed'},
        );
        continue;
      }
      final row = await _resolve(original);
      if (row == null || !current) continue;
      if (!await store.change(
        row,
        ListeningSyncState.dispatched,
        now(),
        expected: ListeningSyncState.queued,
      )) {
        continue;
      }
      try {
        final accepted = await gateway.reportEvent(identity, row.payload);
        await store.change(
          row,
          accepted ? ListeningSyncState.accepted : ListeningSyncState.unknown,
          now(),
        );
      } on Object {
        await store.change(row, ListeningSyncState.unknown, now());
      }
      if (row.text('event') == 'end') _liveSegments.remove(segmentId);
    }
  }

  static bool historyContains(
    List<OfficialHistoryFact> facts,
    ListeningSyncEntry entry,
  ) => facts.any(
    (fact) =>
        fact.recordingId == entry.text('recordingId') &&
        fact.playCount != null &&
        fact.playCount! >= entry.number('playCount') &&
        fact.timeSeconds != null &&
        fact.timeSeconds! >= entry.number('time'),
  );

  Future<void> _history({bool allowWrites = true}) async {
    final rows =
        (await store.entries(
              owner,
              kinds: {'history'},
              states: {
                ListeningSyncState.queued,
                ListeningSyncState.dispatched,
                ListeningSyncState.accepted,
                ListeningSyncState.unknown,
              },
            ))
            .where(
              (r) =>
                  r.kind == 'history' &&
                  {
                    ListeningSyncState.queued,
                    ListeningSyncState.dispatched,
                    ListeningSyncState.accepted,
                    ListeningSyncState.unknown,
                  }.contains(r.state),
            )
            .toList();
    if (rows.isEmpty) return;
    // Check the official state BEFORE submitting old aggregates: an already
    // present history should not be written again merely because we upgraded.
    var facts = await gateway.history(identity);
    var wrote = false;
    var budget = 10;
    final resolved = <ListeningSyncEntry>[];
    for (final original in rows) {
      if (!current) return;
      if (!allowWrites && original.state == ListeningSyncState.queued) continue;
      // Backfilling a large legacy library must not resolve every unknown
      // recording in one drain when only ten writes can be sent this pass.
      if (original.state == ListeningSyncState.queued && budget <= 0) continue;
      final row = original.state == ListeningSyncState.queued
          ? await _resolve(original)
          : original;
      if (row == null) continue;
      resolved.add(row);
      if (historyContains(facts, row)) {
        await store.change(row, ListeningSyncState.verified, now());
        continue;
      }
      // Unknown/dispatched/accepted writes are read-only from now on. Their
      // original time/count is retained across restart and account switches.
      if (row.state != ListeningSyncState.queued || budget-- <= 0 || !current) {
        continue;
      }
      if (!await store.change(
        row,
        ListeningSyncState.dispatched,
        now(),
        expected: ListeningSyncState.queued,
      )) {
        continue;
      }
      try {
        final accepted = await gateway.uploadHistory(
          identity,
          row.text('recordingId'),
          row.number('time'),
          row.number('playCount'),
        );
        await store.change(
          row,
          accepted ? ListeningSyncState.accepted : ListeningSyncState.rejected,
          now(),
        );
      } on Object {
        await store.change(row, ListeningSyncState.unknown, now());
      }
      wrote = true;
    }
    if (wrote && current) {
      facts = await gateway.history(identity);
      for (final row in resolved) {
        if (historyContains(facts, row)) {
          await store.change(row, ListeningSyncState.verified, now());
        }
      }
    }
  }

  Future<void> _grade({bool allowWrites = true}) async {
    final rows = await store.entries(
      owner,
      kinds: {'grade'},
      states: {
        ListeningSyncState.queued,
        ListeningSyncState.dispatched,
        ListeningSyncState.accepted,
        ListeningSyncState.unknown,
      },
    );
    final uncertain = rows
        .where(
          (r) => {
            ListeningSyncState.dispatched,
            ListeningSyncState.accepted,
            ListeningSyncState.unknown,
          }.contains(r.state),
        )
        .toList();
    final queued = rows
        .where((r) => r.state == ListeningSyncState.queued)
        .toList();
    final seconds =
        queued.fold<int>(0, (sum, row) => sum + row.number('heardMs')) ~/ 1000;
    if (uncertain.isEmpty && seconds < 1) return;
    final before = await gateway.gradeSeconds(identity);
    if (before == null || !current) return;
    for (final row in uncertain) {
      if (row.number('target') > 0 && before >= row.number('target')) {
        await store.change(
          row,
          ListeningSyncState.verified,
          now(),
          payload: {...row.payload, 'observedSeconds': before},
        );
      } else {
        // Do not leap over an uncertain delta and then report it twice. Keep
        // later real measurements queued until the server confirms the first.
        return;
      }
    }
    if (seconds < 1 || !current || !allowWrites) return;
    final batch = await store.claimGrade(owner, queued, before, now());
    if (batch == null || !current) return;
    try {
      final accepted = await gateway.reportGrade(
        identity,
        batch.number('baseline'),
        batch.number('diffSec'),
      );
      await store.change(
        batch,
        accepted ? ListeningSyncState.accepted : ListeningSyncState.unknown,
        now(),
      );
    } on Object {
      await store.change(batch, ListeningSyncState.unknown, now());
    }
    if (!current) return;
    final observed = await gateway.gradeSeconds(identity);
    if (observed != null && observed >= batch.number('target')) {
      await store.change(
        batch,
        ListeningSyncState.verified,
        now(),
        payload: {...batch.payload, 'observedSeconds': observed},
      );
    }
  }
}
