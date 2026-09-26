import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/models/room.dart';
import 'package:karaoki/providers/app_state.dart';
import 'package:karaoki/services/auth_service.dart';
import 'package:karaoki/services/realtime_sync_service.dart';

void main() {
  group('AppState.playerScores', () {
    late AppState appState;

    setUp(() {
      appState = AppState(AuthService());
      appState.updatePlayers([
        const Player(id: 'a', name: 'Ada'),
        const Player(id: 'b', name: 'Ben'),
      ]);
    });

    test('starts empty', () {
      expect(appState.playerScores, isEmpty);
      expect(appState.scoreFor('a'), isNull);
    });

    test('performance_update records the live score per singer', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceUpdate,
        senderId: 'b',
        data: {'singerId': 'b', 'score': 55},
      ));
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceUpdate,
        senderId: 'b',
        data: {'singerId': 'b', 'score': 77},
      ));

      expect(appState.scoreFor('b'), 77);
      expect(appState.scoreFor('a'), isNull);
      // Latest tick wins.
      expect(appState.playerScores['b'], 77);
    });

    test('performance_complete finalizes the score in the map', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceComplete,
        senderId: 'a',
        data: {'singerId': 'a', 'score': 999},
      ));
      expect(appState.scoreFor('a'), 999);
    });

    test('events without a score do not touch the map', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceUpdate,
        senderId: 'a',
        data: {'singerId': 'a', 'pitch': 80},
      ));
      expect(appState.playerScores, isEmpty);
    });

    test('leaving the room clears the scores', () {
      appState.applySyncEvent(SyncEvent(
        type: SyncEventType.performanceComplete,
        senderId: 'a',
        data: {'singerId': 'a', 'score': 42},
      ));
      expect(appState.playerScores, isNotEmpty);

      appState.leaveRoom();
      expect(appState.playerScores, isEmpty);
    });

    test('returned map is unmodifiable', () {
      expect(() => appState.playerScores['a'] = 5, throwsUnsupportedError);
    });
  });
}
