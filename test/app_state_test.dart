import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/models/room.dart';
import 'package:karaoki/providers/app_state.dart';
import 'package:karaoki/services/realtime_sync_service.dart';

void main() {
  group('ScoreBreakdown', () {
    test('overall blends pitch/timing/consistency/energy with weights', () {
      const breakdown = ScoreBreakdown(
        pitch: 100,
        timing: 100,
        consistency: 100,
        energy: 100,
      );
      expect(breakdown.overall, 100);
    });

    test('overall weights pitch 40%, timing 30%, rest 15% each', () {
      const breakdown = ScoreBreakdown(
        pitch: 100,
        timing: 0,
        consistency: 0,
        energy: 0,
      );
      expect(breakdown.overall, 40);

      const timingOnly = ScoreBreakdown(
        pitch: 0,
        timing: 100,
        consistency: 0,
        energy: 0,
      );
      expect(timingOnly.overall, 30);

      const energyOnly = ScoreBreakdown(
        pitch: 0,
        timing: 0,
        consistency: 0,
        energy: 100,
      );
      expect(energyOnly.overall, 15);
    });

    test('rank thresholds map to expected labels', () {
      expect(
        const ScoreBreakdown(pitch: 95, timing: 95, consistency: 95, energy: 95)
            .rank,
        'SUPERSTAR',
      );
      expect(
        const ScoreBreakdown(pitch: 80, timing: 80, consistency: 80, energy: 80)
            .rank,
        'GREAT',
      );
      expect(
        const ScoreBreakdown(pitch: 65, timing: 65, consistency: 65, energy: 65)
            .rank,
        'SOLID',
      );
      expect(
        const ScoreBreakdown(pitch: 10, timing: 10, consistency: 10, energy: 10)
            .rank,
        'KEEP GOING',
      );
    });
  });

  group('AppState.applySyncEvent', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
      appState.updatePlayers([
        const Player(id: 'a', name: 'Ada'),
        const Player(id: 'b', name: 'Ben'),
      ]);
    });

    test('player_ready flips the ready flag for that player only', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.playerReady,
        senderId: 'a',
        data: {'playerId': 'a', 'ready': true},
      ));

      expect(appState.players.firstWhere((p) => p.id == 'a').ready, true);
      expect(appState.players.firstWhere((p) => p.id == 'b').ready, false);
    });

    test('player_joined appends a new player and ignores duplicates', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.playerJoined,
        senderId: 'c',
        data: {'playerId': 'c', 'name': 'Cleo'},
      ));
      expect(appState.players.length, 3);
      expect(appState.players.last.id, 'c');
      expect(appState.players.last.name, 'Cleo');

      // Duplicate join must not add another row.
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.playerJoined,
        senderId: 'c',
        data: {'playerId': 'c', 'name': 'Cleo'},
      ));
      expect(appState.players.length, 3);
    });

    test('player_left removes only that player', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.playerLeft,
        senderId: 'a',
        data: {'playerId': 'a'},
      ));
      expect(appState.players.length, 1);
      expect(appState.players.single.id, 'b');
    });

    test('performance_update stores the live score on the singer', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceUpdate,
        senderId: 'b',
        data: {'singerId': 'b', 'score': 1234},
      ));
      expect(appState.players.firstWhere((p) => p.id == 'b').score, 1234);
    });

    test('performance_complete finalizes the score on the singer', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceComplete,
        senderId: 'a',
        data: {'singerId': 'a', 'score': 999},
      ));
      expect(appState.players.firstWhere((p) => p.id == 'a').score, 999);
    });

    test('setLastBreakdown stores and clearLastBreakdown resets', () {
      appState.setLastBreakdown(pitch: 90, timing: 80, consistency: 70, energy: 60);
      expect(appState.lastBreakdown, isNotNull);
      expect(appState.lastBreakdown!.overall, greaterThan(0));

      appState.clearLastBreakdown();
      expect(appState.lastBreakdown, isNull);
    });

    test('notifications fire for listeners on applied events', () {
      var notified = 0;
      appState.addListener(() => notified++);
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.playerReady,
        senderId: 'a',
        data: {'playerId': 'a', 'ready': true},
      ));
      expect(notified, 1);
    });
  });
}
