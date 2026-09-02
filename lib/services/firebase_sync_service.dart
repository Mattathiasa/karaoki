import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'realtime_sync_service.dart';

/// Firebase Realtime Database implementation of RealtimeSyncService.
///
/// Uses a per-room events node for broadcasting sync events between
/// phone and TV clients. Events are ephemeral (written, read once, then
/// cleaned up by TTL or clients).
///
/// Database structure:
///   rooms/{roomId}/events/{eventId} -> SyncEvent JSON
///   rooms/{roomId}/heartbeat/{userId} -> { timestamp, ... }
///
class FirebaseRealtimeSyncService implements RealtimeSyncService {
  final FirebaseDatabase _db;
  StreamSubscription<DatabaseEvent>? _eventSubscription;
  StreamSubscription<DatabaseEvent>? _connectionSubscription;
  final _eventController = StreamController<SyncEvent>.broadcast();
  final _stateController = StreamController<ConnectionState>.broadcast();
  String? _roomId;
  String? _userId;

  FirebaseRealtimeSyncService({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Stream<SyncEvent> get eventStream => _eventController.stream;

  @override
  Stream<ConnectionState> get connectionStateStream => _stateController.stream;

  // ─── Connect ─────────────────────────────────────
  @override
  Future<void> connect(String roomId, {required String userId}) async {
    _roomId = roomId;
    _userId = userId;
    _stateController.add(ConnectionState.connecting);

    // Listen to Firebase connection state
    _connectionSubscription = _db.ref('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        _stateController.add(ConnectionState.connected);
        _setupPresence(roomId, userId);
      } else {
        _stateController.add(ConnectionState.reconnecting);
      }
    });

    // Listen to incoming events
    final eventsRef = _db.ref('rooms/$roomId/events');
    _eventSubscription = eventsRef.orderByChild('timestamp').onChildAdded.listen(
      (event) {
        if (event.snapshot.value == null) return;

        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final syncEvent = SyncEvent.fromJson(data);

        // Ignore events we sent ourselves
        if (syncEvent.senderId == userId) return;

        _eventController.add(syncEvent);

        // Clean up old events (keep last 100)
        _pruneEvents(eventsRef);
      },
      onError: (error) {
        _stateController.add(ConnectionState.reconnecting);
      },
    );
  }

  // ─── Disconnect ──────────────────────────────────
  @override
  Future<void> disconnect() async {
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    _eventSubscription = null;
    _connectionSubscription = null;

    // Remove presence
    if (_roomId != null && _userId != null) {
      await _db.ref('rooms/$_roomId/presence/$_userId').remove();
      await _db.ref('rooms/$_roomId/heartbeat/$_userId').remove();
    }

    _roomId = null;
    _userId = null;
    _stateController.add(ConnectionState.disconnected);
  }

  // ─── Send Event ──────────────────────────────────
  @override
  Future<void> sendEvent(SyncEvent event) async {
    if (_roomId == null) return;

    final eventsRef = _db.ref('rooms/$_roomId/events');
    final eventId = eventsRef.push().key;

    if (eventId != null) {
      await eventsRef.child(eventId).set(event.toJson());
    }
  }

  // ─── Presence ────────────────────────────────────
  void _setupPresence(String roomId, String userId) {
    final presenceRef = _db.ref('rooms/$roomId/presence/$userId');
    final heartbeatRef = _db.ref('rooms/$roomId/heartbeat/$userId');

    // Set online
    presenceRef.set({
      'online': true,
      'lastSeen': ServerValue.timestamp,
    });

    // Set disconnect handler
    presenceRef.onDisconnect().set({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });

    // Periodic heartbeat
    Timer.periodic(const Duration(seconds: 10), (_) {
      if (_roomId != null) {
        heartbeatRef.set({
          'timestamp': ServerValue.timestamp,
          'userId': userId,
        });
      }
    });

    // Update heartbeat on connect
    heartbeatRef.set({
      'timestamp': ServerValue.timestamp,
      'userId': userId,
    });
  }

  // ─── Event Pruning ───────────────────────────────
  void _pruneEvents(DatabaseReference eventsRef) async {
    final snapshot = await eventsRef.get();
    if (!snapshot.exists) return;

    final children = snapshot.children.toList();
    if (children.length > 100) {
      // Remove oldest events
      final toRemove = children.sublist(0, children.length - 100);
      for (final child in toRemove) {
        await child.ref.remove();
      }
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    _eventController.close();
    _stateController.close();
  }
}
