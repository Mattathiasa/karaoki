import 'dart:async';
import 'dart:math';
import '../models/room.dart';
/// Abstract room service: in production backed by Firebase Realtime Database
abstract class RoomService {
  Future<Room> createRoom({
    required String name,
    required String hostId,
    GameMode mode = GameMode.classic,
    int maxPlayers = 8,
  });

  Future<Room> joinRoom({required String code, required String userId});

  Stream<List<Player>> watchPlayers(String roomId);

  Stream<Room> watchRoom(String roomId);

  Future<void> toggleReady(String roomId, String playerId);

  Future<void> addSong(String roomId, String songId, String requestedBy);

  Future<void> startGame(String roomId);

  Future<void> leaveRoom(String roomId, String playerId);

  Future<void> updatePerformance(String roomId, String singerId, int score);

  Future<void> advanceTurn(String roomId);
}

/// Stub implementation for development - simulates real-time behavior
class StubRoomService implements RoomService {
  final _rooms = <String, Room>{};
  final _players = <String, List<Player>>{};
  final _queue = <String, List<QueueEntry>>{};
  final _roomControllers = <String, StreamController<Room>>{};
  final _playerControllers = <String, StreamController<List<Player>>>{};

  @override
  Future<Room> createRoom({
    required String name,
    required String hostId,
    GameMode mode = GameMode.classic,
    int maxPlayers = 8,
  }) async {
    final code = _generateCode();
    final room = Room(
      id: 'room-${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      name: name,
      hostId: hostId,
      mode: mode,
      maxPlayers: maxPlayers,
    );
    _rooms[room.id] = room;
    _players[room.id] = [
      Player(id: hostId, name: 'Host', level: 1, ready: true),
    ];
    _queue[room.id] = [];

    // Set up stream controllers
    _roomControllers[room.id] = StreamController<Room>.broadcast();
    _playerControllers[room.id] = StreamController<List<Player>>.broadcast();

    // Emit initial state
    _roomControllers[room.id]!.add(room);
    _playerControllers[room.id]!.add(_players[room.id]!);

    return room;
  }

  @override
  Future<Room> joinRoom({required String code, required String userId}) async {
    final room = _rooms.values.firstWhere(
      (r) => r.code == code,
      orElse: () => throw Exception('Room not found'),
    );
    final playerList = _players[room.id] ?? [];
    if (playerList.length >= room.maxPlayers) {
      throw Exception('Room is full');
    }
    playerList.add(Player(id: userId, name: 'Guest ${playerList.length + 1}', level: 1));
    _players[room.id] = playerList;

    // Notify listeners
    _playerControllers[room.id]?.add(playerList);
    _roomControllers[room.id]?.add(room);

    return room;
  }

  @override
  Stream<List<Player>> watchPlayers(String roomId) {
    if (!_playerControllers.containsKey(roomId)) {
      _playerControllers[roomId] = StreamController<List<Player>>.broadcast();
    }
    // Emit current state immediately
    Future.microtask(() => _playerControllers[roomId]!.add(_players[roomId] ?? []));
    return _playerControllers[roomId]!.stream;
  }

  @override
  Stream<Room> watchRoom(String roomId) {
    if (!_roomControllers.containsKey(roomId)) {
      _roomControllers[roomId] = StreamController<Room>.broadcast();
    }
    final room = _rooms[roomId];
    if (room != null) {
      Future.microtask(() => _roomControllers[roomId]!.add(room));
    }
    return _roomControllers[roomId]!.stream;
  }

  @override
  Future<void> toggleReady(String roomId, String playerId) async {
    final players = _players[roomId];
    if (players == null) return;
    final index = players.indexWhere((p) => p.id == playerId);
    if (index == -1) return;
    final p = players[index];
    players[index] = Player(
      id: p.id,
      name: p.name,
      level: p.level,
      ready: !p.ready,
      connected: p.connected,
    );
    _playerControllers[roomId]?.add(List.from(players));
  }

  @override
  Future<void> addSong(String roomId, String songId, String requestedBy) async {
    final entries = _queue[roomId];
    if (entries == null) return;
    entries.add(QueueEntry(
      entryId: 'entry-${DateTime.now().millisecondsSinceEpoch}',
      songId: songId,
      requestedBy: requestedBy,
      position: entries.length + 1,
    ));
  }

  @override
  Future<void> startGame(String roomId) async {
    _rooms[roomId] = _rooms[roomId]!.copyWith(status: RoomStatus.countdown);
    _roomControllers[roomId]?.add(_rooms[roomId]!);
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    _players[roomId]?.removeWhere((p) => p.id == playerId);
    _playerControllers[roomId]?.add(_players[roomId] ?? []);
  }

  @override
  Future<void> updatePerformance(String roomId, String singerId, int score) async {
    final room = _rooms[roomId];
    if (room == null) return;
    // Update player score
    final playerList = _players[roomId];
    if (playerList != null) {
      final idx = playerList.indexWhere((p) => p.id == singerId);
      if (idx != -1) {
        final p = playerList[idx];
        playerList[idx] = Player(
          id: p.id, name: p.name, level: p.level,
          ready: p.ready, connected: p.connected, score: score,
        );
        _playerControllers[roomId]?.add(List.from(playerList));
      }
    }
  }

  @override
  Future<void> advanceTurn(String roomId) async {
    final room = _rooms[roomId];
    if (room == null) return;
    final playerList = _players[roomId] ?? [];
    if (playerList.isEmpty) return;

    // Find next ready player
    final currentIdx = _currentSingerIndices[roomId] ?? 0;
    final nextIdx = (currentIdx + 1) % playerList.length;
    _currentSingerIndices[roomId] = nextIdx;

    _rooms[roomId] = room.copyWith(status: RoomStatus.performing);
    _roomControllers[roomId]?.add(_rooms[roomId]!);
  }

  final _currentSingerIndices = <String, int>{};

  String _generateCode() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rng = Random();
    String code = 'KARA-';
    for (int i = 0; i < 4; i++) {
      code += letters[rng.nextInt(26)];
    }
    return code;
  }

  void dispose() {
    for (final c in _roomControllers.values) {
      c.close();
    }
    for (final c in _playerControllers.values) {
      c.close();
    }
  }
}
