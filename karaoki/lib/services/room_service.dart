import '../models/room.dart';

/// Abstract room service — in production backed by Firebase Realtime Database
abstract class RoomService {
  Future<Room> createRoom({
    required String name,
    required String hostId,
    GameMode mode = GameMode.classic,
    int maxPlayers = 8,
  });

  Future<Room> joinRoom({required String code, required String userId});

  Stream<List<Player>> watchPlayers(String roomId);

  Future<void> toggleReady(String roomId, String playerId);

  Future<void> addSong(String roomId, String songId, String requestedBy);

  Future<void> startGame(String roomId);

  Future<void> leaveRoom(String roomId, String playerId);
}

/// Stub implementation for development
class StubRoomService implements RoomService {
  final _rooms = <String, Room>{};
  final _players = <String, List<Player>>{};
  final _queue = <String, List<QueueEntry>>{};

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
    return room;
  }

  @override
  Future<Room> joinRoom({required String code, required String userId}) async {
    final room = _rooms.values.firstWhere(
      (r) => r.code == code,
      orElse: () => throw Exception('Room not found'),
    );
    _players[room.id]?.add(
      Player(id: userId, name: 'Guest', level: 1),
    );
    return room;
  }

  @override
  Stream<List<Player>> watchPlayers(String roomId) {
    return Stream.value(_players[roomId] ?? []);
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
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    _players[roomId]?.removeWhere((p) => p.id == playerId);
  }

  String _generateCode() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    final rng = DateTime.now().microsecondsSinceEpoch;
    String code = 'KARA-';
    for (int i = 0; i < 4; i++) {
      code += letters[(rng >> (i * 3)) % 26];
    }
    return code;
  }
}
