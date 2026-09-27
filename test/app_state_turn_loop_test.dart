import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/models/room.dart';
import 'package:karaoki/models/song.dart';
import 'package:karaoki/providers/app_state.dart';
import 'package:karaoki/services/auth_service.dart';
import 'package:karaoki/services/realtime_sync_service.dart';

AppState makeState() => AppState(AuthService());

void main() {
  group('AppState turn loop', () {
    test('nextUpEntry falls back to the first queued entry', () {
      final state = makeState();
      state.updateQueue(const [
        QueueEntry(entryId: 'e1', songId: 's1', requestedBy: 'p1', position: 1),
        QueueEntry(entryId: 'e2', songId: 's2', requestedBy: 'p2', position: 2),
      ]);
      expect(state.activeEntryId, isNull);
      expect(state.nextUpEntry?.entryId, 'e1');
      expect(state.upcomingEntries.map((e) => e.entryId), ['e1', 'e2']);
    });

    test('setActiveEntry marks the entry playing and hides it from upcoming',
        () {
      final state = makeState();
      state.updateQueue(const [
        QueueEntry(entryId: 'e1', songId: 's1', requestedBy: 'p1', position: 1),
        QueueEntry(entryId: 'e2', songId: 's2', requestedBy: 'p2', position: 2),
      ]);
      state.setActiveEntry('e1');
      expect(state.activeEntry?.state, QueueEntryState.playing);
      expect(state.nextUpEntry?.entryId, 'e1');
      expect(state.upcomingEntries.map((e) => e.entryId), ['e2']);
    });

    test('advanceQueue marks the active entry done and promotes the next',
        () {
      final state = makeState();
      state.updateQueue(const [
        QueueEntry(entryId: 'e1', songId: 's1', requestedBy: 'p1', position: 1),
        QueueEntry(entryId: 'e2', songId: 's2', requestedBy: 'p2', position: 2),
      ]);
      state.setActiveEntry('e1');
      final next = state.advanceQueue();
      expect(next?.entryId, 'e2');
      expect(state.activeEntry?.entryId, 'e2');
      expect(state.activeEntry?.state, QueueEntryState.playing);
      // The finished entry is marked done and out of the way.
      expect(
        state.queue.firstWhere((e) => e.entryId == 'e1').state,
        QueueEntryState.done,
      );
    });

    test('advanceQueue returns null and clears the active entry when done',
        () {
      final state = makeState();
      state.updateQueue(const [
        QueueEntry(entryId: 'e1', songId: 's1', requestedBy: 'p1', position: 1),
      ]);
      state.setActiveEntry('e1');
      expect(state.advanceQueue(), isNull);
      expect(state.activeEntryId, isNull);
      expect(state.nextUpEntry, isNull);
    });

    test('leaveRoom resets the active entry and queue', () {
      final state = makeState();
      state.updateQueue(const [
        QueueEntry(entryId: 'e1', songId: 's1', requestedBy: 'p1', position: 1),
      ]);
      state.setActiveEntry('e1');
      state.leaveRoom();
      expect(state.activeEntryId, isNull);
      expect(state.queue, isEmpty);
    });

    test('clearLiveScores clears per-singer metrics too', () {
      final state = makeState();
      state.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceUpdate,
        senderId: 'p1',
        data: {'singerId': 'p1', 'score': 60, 'pitch': 70, 'combo': 3},
      ));
      expect(state.liveMetricsFor('p1')['pitch'], 70);
      state.clearLiveScores();
      expect(state.liveMetricsFor('p1'), isEmpty);
      expect(state.scoreFor('p1'), isNull);
    });
  });

  group('AppState queue events', () {
    test('songAdded appends a queue entry for remote requests', () {
      final state = makeState();
      state.applySyncEvent(SyncEvent(
        type: SyncEventType.songAdded,
        senderId: 'p2',
        data: {'songId': 'neon-midnight', 'requestedBy': 'p2'},
      ));
      expect(state.queue.length, 1);
      expect(state.queue.first.songId, 'neon-midnight');
      expect(state.queue.first.requestedBy, 'p2');
    });

    test('songAdded ignores duplicate song+requester pairs', () {
      final state = makeState();
      final event = SyncEvent(
        type: SyncEventType.songAdded,
        senderId: 'p2',
        data: {'songId': 'neon-midnight', 'requestedBy': 'p2'},
      );
      state.applySyncEvent(event);
      state.applySyncEvent(event);
      expect(state.queue.length, 1);
    });

    test('songRemoved drops the entry by id', () {
      final state = makeState();
      state.updateQueue(const [
        QueueEntry(entryId: 'e1', songId: 's1', requestedBy: 'p1', position: 1),
      ]);
      state.applySyncEvent(SyncEvent(
        type: SyncEventType.songRemoved,
        senderId: 'p2',
        data: {'entryId': 'e1'},
      ));
      expect(state.queue, isEmpty);
    });

    test('playerJoined refreshes an existing player name', () {
      final state = makeState();
      state.updatePlayers(const [Player(id: 'p1', name: 'Old')]);
      state.applySyncEvent(SyncEvent(
        type: SyncEventType.playerJoined,
        senderId: 'p1',
        data: {'playerId': 'p1', 'name': 'New'},
      ));
      expect(state.players.single.name, 'New');
    });
  });

  group('QueueEntry model', () {
    test('copyWith preserves identity and swaps state/position', () {
      const entry = QueueEntry(
        entryId: 'e1', songId: 's1', requestedBy: 'p1', position: 1,
      );
      final playing = entry.copyWith(state: QueueEntryState.playing);
      expect(playing.entryId, 'e1');
      expect(playing.state, QueueEntryState.playing);
      expect(playing.position, 1);
      final moved = playing.copyWith(position: 7);
      expect(moved.position, 7);
      expect(moved.state, QueueEntryState.playing);
    });
  });

  group('Fixture songs carry playable backing tracks', () {
    test('every fixture song has an audio asset wired up', () {
      for (final song in fixtureSongs) {
        expect(song.audioUrl, isNotNull,
            reason: '${song.id} is missing audioUrl');
        expect(song.audioUrl, startsWith('assets/audio/'),
            reason: '${song.id} audioUrl should point at a bundled asset');
      }
    });

    test('every fixture song keeps a usable duration', () {
      for (final song in fixtureSongs) {
        expect(song.duration.inMilliseconds, greaterThan(0));
      }
    });
  });
}
