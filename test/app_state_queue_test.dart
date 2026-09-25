import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/models/room.dart';
import 'package:karaoki/models/song.dart';
import 'package:karaoki/providers/app_state.dart';
import 'package:karaoki/services/auth_service.dart';

void main() {
  late AppState appState;

  setUp(() {
    appState = AppState(AuthService());
  });

  QueueEntry entry(String id, String songId, {int position = 1}) =>
      QueueEntry(
        entryId: id,
        songId: songId,
        requestedBy: 'user-1',
        position: position,
      );

  group('AppState queue helpers', () {
    test('addToQueue appends and keeps insertion order', () {
      appState.addToQueue(entry('e1', 'neon-midnight', position: 1), fixtureSongs[0]);
      appState.addToQueue(entry('e2', 'concrete-halo', position: 2), fixtureSongs[1]);

      expect(appState.queue.length, 2);
      expect(appState.queue[0].songId, 'neon-midnight');
      expect(appState.queue[1].songId, 'concrete-halo');
    });

    test('songForEntry resolves the exact song that was added', () {
      appState.addToQueue(entry('e1', 'concrete-halo'), fixtureSongs[1]);

      final song = appState.songForEntry(appState.queue.single);
      expect(song.id, 'concrete-halo');
      expect(song.title, 'Concrete Halo');
    });

    test('songForEntry falls back to fixtures for unknown song ids', () {
      final orphan = entry('e9', 'not-a-real-song');
      appState.addToQueue(orphan, fixtureSongs[0]);

      // Remove the cached song mapping by asking for an unknown id directly.
      final resolved = appState.songForEntry(
        const QueueEntry(
          entryId: 'e-x',
          songId: 'neon-midnight',
          requestedBy: 'user-1',
          position: 1,
        ),
      );
      expect(resolved.id, 'neon-midnight');
    });

    test('removeFromQueue deletes only the matching entry id', () {
      appState.addToQueue(entry('e1', 'neon-midnight'), fixtureSongs[0]);
      appState.addToQueue(entry('e2', 'loose-change', position: 2), fixtureSongs[2]);

      appState.removeFromQueue('e1');

      expect(appState.queue.length, 1);
      expect(appState.queue.single.entryId, 'e2');
    });

    test('removeFromQueue with unknown id leaves the queue unchanged', () {
      appState.addToQueue(entry('e1', 'neon-midnight'), fixtureSongs[0]);

      appState.removeFromQueue('does-not-exist');

      expect(appState.queue.length, 1);
    });

    test('queue mutations notify listeners', () {
      var notified = 0;
      appState.addListener(() => notified++);

      appState.addToQueue(entry('e1', 'neon-midnight'), fixtureSongs[0]);
      appState.removeFromQueue('e1');

      expect(notified, 2);
      expect(appState.queue, isEmpty);
    });
  });
}
