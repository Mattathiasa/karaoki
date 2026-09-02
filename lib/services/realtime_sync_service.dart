import 'dart:async';
import 'dart:convert';
/// Real-time sync service for phone <-> TV communication
/// Uses WebSocket under the hood; in production swap for Firebase Realtime DB
abstract class RealtimeSyncService {
  /// Connect to a room's real-time channel
  Future<void> connect(String roomId, {required String userId});

  /// Disconnect from the room
  Future<void> disconnect();

  /// Send an event to all connected clients in the room
  Future<void> sendEvent(SyncEvent event);

  /// Stream of incoming events from other clients
  Stream<SyncEvent> get eventStream;

  /// Connection state stream
  Stream<ConnectionState> get connectionStateStream;
}

enum ConnectionState { disconnected, connecting, connected, reconnecting }

/// Events synced between phone and TV
class SyncEvent {
  final String type;
  final String senderId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SyncEvent({
    required this.type,
    required this.senderId,
    this.data = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type,
    'senderId': senderId,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SyncEvent.fromJson(Map<String, dynamic> json) => SyncEvent(
    type: json['type'] as String,
    senderId: json['senderId'] as String,
    data: Map<String, dynamic>.from(json['data'] ?? {}),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  String encode() => jsonEncode(toJson());

  static SyncEvent decode(String encoded) => SyncEvent.fromJson(
    jsonDecode(encoded) as Map<String, dynamic>,
  );
}

/// Event types
class SyncEventType {
  static const playerJoined = 'player_joined';
  static const playerLeft = 'player_left';
  static const playerReady = 'player_ready';
  static const songAdded = 'song_added';
  static const songRemoved = 'song_removed';
  static const gameStarted = 'game_started';
  static const turnAdvanced = 'turn_advanced';
  static const performanceUpdate = 'performance_update';
  static const performanceComplete = 'performance_complete';
  static const chatMessage = 'chat_message';
  static const ping = 'ping';
  static const pong = 'pong';
}

/// Stub implementation for local network dev
class StubRealtimeSyncService implements RealtimeSyncService {
  final _eventController = StreamController<SyncEvent>.broadcast();
  final _stateController = StreamController<ConnectionState>.broadcast();
  String? _roomId;

  @override
  Stream<SyncEvent> get eventStream => _eventController.stream;

  @override
  Stream<ConnectionState> get connectionStateStream => _stateController.stream;

  @override
  Future<void> connect(String roomId, {required String userId}) async {
    _roomId = roomId;
    _stateController.add(ConnectionState.connecting);

    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 300));
    _stateController.add(ConnectionState.connected);

    // Simulate ping/pong
    Timer.periodic(const Duration(seconds: 5), (_) {
      if (_roomId != null) {
        sendEvent(SyncEvent(type: SyncEventType.ping, senderId: 'system'));
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _roomId = null;
    _stateController.add(ConnectionState.disconnected);
  }

  @override
  Future<void> sendEvent(SyncEvent event) async {
    // In production: WebSocket.send(event.encode())
    // For stub: echo back to simulate network
    _eventController.add(event);
  }
}
