import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/room.dart';
import 'room_service.dart';

/// Firebase Realtime Database implementation of RoomService.
///
/// Database structure:
///   rooms/{roomId}          -> Room JSON
///   rooms/{roomId}/players  -> { playerId: Player JSON }
///   rooms/{roomId}/queue    -> { entryId: QueueEntry JSON }
///   rooms/{roomId}/presence -> { userId: { online: true, lastSeen: timestamp } }
///
/// Room codes are stored in a lookup table:
///   roomCodes/{CODE} -> roomId
///
class FirebaseRoomService implements RoomService {
  final FirebaseDatabase _db;

  FirebaseRoomService({FirebaseDatabase? db}) : _db = db ?? FirebaseDatabase.instance;

  // ─── References ──────────────────────────────────
  DatabaseReference _roomRef(String roomId) => _db.ref('rooms/$roomId');
  DatabaseReference _playersRef(String roomId) => _db.ref('rooms/$roomId/players');
  DatabaseReference _queueRef(String roomId) => _db.ref('rooms/$roomId/queue');
  DatabaseReference _presenceRef(String roomId, String userId) =>
      _db.ref('rooms/$roomId/presence/$userId');
  DatabaseReference _codeRef(String code) => _db.ref('roomCodes/$code');

  // ─── Create Room ─────────────────────────────────
  @override
  Future<Room> createRoom({
    required String name,
    required String hostId,
    GameMode mode = GameMode.classic,
    int maxPlayers = 8,
  }) async {
    final code = await _generateUniqueCode();
    final roomId = _db.ref('rooms').push().key!;

    final room = Room(
      id: roomId,
      code: code,
      name: name,
      hostId: hostId,
      mode: mode,
      maxPlayers: maxPlayers,
    );

    // Write room data
    await _roomRef(roomId).set(room.toJson());

    // Write code lookup
    await _codeRef(code).set(roomId);

    // Add host as first player
    final hostPlayer = Player(
      id: hostId,
      name: 'Host',
      level: 1,
      ready: true,
      connected: true,
    );
    await _playersRef(roomId).child(hostId).set(hostPlayer.toJson());

    // Set presence
    await _presenceRef(roomId, hostId).set({
      'online': true,
      'lastSeen': ServerValue.timestamp,
    });

    return room;
  }

  // ─── Join Room ───────────────────────────────────
  @override
  Future<Room> joinRoom({required String code, required String userId}) async {
    final normalizedCode = code.toUpperCase().trim();

    // Look up roomId from code
    final codeSnapshot = await _codeRef(normalizedCode).get();
    if (!codeSnapshot.exists) {
      throw Exception('Room not found');
    }
    final roomId = codeSnapshot.value as String;

    // Get room
    final roomSnapshot = await _roomRef(roomId).get();
    if (!roomSnapshot.exists) {
      throw Exception('Room not found');
    }
    final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);
    final room = Room.fromJson(roomData);

    // Check player count
    final playersSnapshot = await _playersRef(roomId).get();
    final playerCount = playersSnapshot.children.length;
    if (playerCount >= room.maxPlayers) {
      throw Exception('Room is full');
    }

    // Check if player already in room
    final existingPlayer = await _playersRef(roomId).child(userId).get();
    if (existingPlayer.exists) {
      // Player reconnecting, just update presence
      await _presenceRef(roomId, userId).set({
        'online': true,
        'lastSeen': ServerValue.timestamp,
      });
      return room;
    }

    // Add player
    final player = Player(
      id: userId,
      name: 'Player $playerCount',
      level: 1,
      ready: false,
      connected: true,
    );
    await _playersRef(roomId).child(userId).set(player.toJson());

    // Set presence
    await _presenceRef(roomId, userId).set({
      'online': true,
      'lastSeen': ServerValue.timestamp,
    });

    return room;
  }

  // ─── Watch Players (real-time stream) ────────────
  @override
  Stream<List<Player>> watchPlayers(String roomId) {
    final controller = StreamController<List<Player>>.broadcast();

    _playersRef(roomId).onValue.listen((event) {
      if (!event.snapshot.exists) {
        controller.add([]);
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final players = data.entries.map((entry) {
        final playerData = Map<String, dynamic>.from(entry.value as Map);
        return Player.fromJson(playerData);
      }).toList();

      // Sort by join order (score ascending as tiebreaker)
      players.sort((a, b) => a.id.compareTo(b.id));

      controller.add(players);
    }).onError((error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  // ─── Watch Room (real-time stream) ───────────────
  @override
  Stream<Room> watchRoom(String roomId) {
    final controller = StreamController<Room>.broadcast();

    _roomRef(roomId).onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final room = Room.fromJson(data);
      controller.add(room);
    }).onError((error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  // ─── Toggle Ready ────────────────────────────────
  @override
  Future<void> toggleReady(String roomId, String playerId) async {
    final snapshot = await _playersRef(roomId).child(playerId).get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final currentReady = data['ready'] as bool? ?? false;

    await _playersRef(roomId).child(playerId).update({
      'ready': !currentReady,
    });
  }

  // ─── Add Song to Queue ───────────────────────────
  @override
  Future<void> addSong(String roomId, String songId, String requestedBy) async {
    final entryId = _queueRef(roomId).push().key!;
    final entry = QueueEntry(
      entryId: entryId,
      songId: songId,
      requestedBy: requestedBy,
      position: await _getNextQueuePosition(roomId),
    );
    await _queueRef(roomId).child(entryId).set(entry.toJson());
  }

  // ─── Start Game ──────────────────────────────────
  @override
  Future<void> startGame(String roomId) async {
    await _roomRef(roomId).update({
      'status': RoomStatus.countdown.name,
    });
  }

  // ─── Leave Room ──────────────────────────────────
  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    // Remove player
    await _playersRef(roomId).child(playerId).remove();

    // Remove presence
    await _presenceRef(roomId, playerId).remove();

    // Check if room is now empty
    final playersSnapshot = await _playersRef(roomId).get();
    if (!playersSnapshot.exists || playersSnapshot.children.isEmpty) {
      // Clean up empty room
      await _cleanupRoom(roomId);
    } else {
      // Check if host left, transfer to next player
      final roomSnapshot = await _roomRef(roomId).get();
      if (roomSnapshot.exists) {
        final data = Map<String, dynamic>.from(roomSnapshot.value as Map);
        final hostId = data['hostId'] as String;
        if (hostId == playerId) {
          final firstPlayer = playersSnapshot.children.first;
          final newHostId = firstPlayer.key!;
          await _roomRef(roomId).update({'hostId': newHostId});
          await _playersRef(roomId).child(newHostId).update({'ready': true});
        }
      }
    }
  }

  // ─── Update Performance ──────────────────────────
  @override
  Future<void> updatePerformance(String roomId, String singerId, int score) async {
    await _playersRef(roomId).child(singerId).update({'score': score});
  }

  // ─── Advance Turn ────────────────────────────────
  @override
  Future<void> advanceTurn(String roomId) async {
    // Move to next queue entry
    final queueSnapshot = await _queueRef(roomId).orderByChild('position').get();
    if (queueSnapshot.exists) {
      final entries = <MapEntry<String, dynamic>>[];
      for (final child in queueSnapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        if (data['state'] == QueueEntryState.queued.name) {
          entries.add(MapEntry(child.key!, data));
        }
      }

      // Mark current playing entry as done
      for (final child in queueSnapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        if (data['state'] == QueueEntryState.playing.name) {
          await _queueRef(roomId).child(child.key!).update({
            'state': QueueEntryState.done.name,
          });
        }
      }

      // Mark next entry as playing
      if (entries.isNotEmpty) {
        await _queueRef(roomId).child(entries.first.key).update({
          'state': QueueEntryState.playing.name,
        });
      }
    }

    await _roomRef(roomId).update({
      'status': RoomStatus.performing.name,
    });
  }

  // ─── Watch Queue ─────────────────────────────────
  Stream<List<QueueEntry>> watchQueue(String roomId) {
    final controller = StreamController<List<QueueEntry>>.broadcast();

    _queueRef(roomId).orderByChild('position').onValue.listen((event) {
      if (!event.snapshot.exists) {
        controller.add([]);
        return;
      }

      final entries = <QueueEntry>[];
      for (final child in event.snapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        entries.add(QueueEntry.fromJson(data));
      }

      controller.add(entries);
    }).onError((error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  // ─── Helpers ─────────────────────────────────────
  Future<int> _getNextQueuePosition(String roomId) async {
    final snapshot = await _queueRef(roomId).orderByChild('position').get();
    if (!snapshot.exists) return 1;
    int maxPos = 0;
    for (final child in snapshot.children) {
      final data = Map<String, dynamic>.from(child.value as Map);
      final pos = (data['position'] as num?)?.toInt() ?? 0;
      if (pos > maxPos) maxPos = pos;
    }
    return maxPos + 1;
  }

  Future<String> _generateUniqueCode() async {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // removed I/O to avoid confusion
    final rng = Random();

    for (int attempt = 0; attempt < 10; attempt++) {
      String code = 'KARA-';
      for (int i = 0; i < 4; i++) {
        code += letters[rng.nextInt(letters.length)];
      }

      // Check if code is already in use
      final snapshot = await _codeRef(code).get();
      if (!snapshot.exists) {
        return code;
      }
    }

    // Fallback: use timestamp-based code
    return 'KARA-${DateTime.now().millisecondsSinceEpoch % 10000}'.padRight(9, '0');
  }

  Future<void> _cleanupRoom(String roomId) async {
    // Remove code lookup
    final roomSnapshot = await _roomRef(roomId).get();
    if (roomSnapshot.exists) {
      final data = Map<String, dynamic>.from(roomSnapshot.value as Map);
      final code = data['code'] as String?;
      if (code != null) {
        await _codeRef(code).remove();
      }
    }

    // Remove room data
    await _roomRef(roomId).remove();
  }

  void dispose() {
    _db.goOffline();
  }
}
