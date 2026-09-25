import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../models/song.dart';
import '../services/realtime_sync_service.dart';

/// Central app state managed by Provider
/// Holds room state, player identity, queue, and game flow
class AppState extends ChangeNotifier {
  // ─── User Identity ─────────────────────────────
  final String _userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
  String _userName = 'Player';
  final String _userAvatar = '';
  int _userLevel = 1;

  String get userId => _userId;
  String get userName => _userName;
  String get userAvatar => _userAvatar;
  int get userLevel => _userLevel;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserLevel(int level) {
    _userLevel = level;
    notifyListeners();
  }

  // ─── Room State ────────────────────────────────
  Room? _currentRoom;
  Room? get currentRoom => _currentRoom;

  List<Player> _players = [];
  List<Player> get players => _players;

  bool _isHost = false;
  bool get isHost => _isHost;

  void setRoom(Room room, {bool isHost = false}) {
    _currentRoom = room;
    _isHost = isHost;
    notifyListeners();
  }

  void updatePlayers(List<Player> players) {
    _players = players;
    notifyListeners();
  }

  void leaveRoom() {
    _currentRoom = null;
    _players = [];
    _isHost = false;
    _queue = [];
    _currentSingerIndex = 0;
    notifyListeners();
  }

  // ─── Queue ─────────────────────────────────────
  List<QueueEntry> _queue = [];
  List<QueueEntry> get queue => _queue;

  void updateQueue(List<QueueEntry> entries) {
    _queue = entries;
    notifyListeners();
  }

  // ─── Game Flow ─────────────────────────────────
  int _currentSingerIndex = 0;
  int get currentSingerIndex => _currentSingerIndex;

  void nextSinger() {
    _currentSingerIndex = (_currentSingerIndex + 1) % _players.length;
    notifyListeners();
  }

  Player? get currentPlayer =>
      _players.isNotEmpty ? _players[_currentSingerIndex % _players.length] : null;

  // ─── Performance ───────────────────────────────
  Song? _currentSong;
  Song? get currentSong => _currentSong;

  int _liveScore = 0;
  int get liveScore => _liveScore;

  /// Final score breakdown of the last completed performance. Populated by
  /// SingingScreen when the performance ends; consumed by CompleteScreen.
  ScoreBreakdown? _lastBreakdown;
  ScoreBreakdown? get lastBreakdown => _lastBreakdown;

  void setCurrentSong(Song song) {
    _currentSong = song;
    notifyListeners();
  }

  void updateLiveScore(int score) {
    _liveScore = score;
    notifyListeners();
  }

  /// Store the final score breakdown for the performance that just ended.
  void setLastBreakdown({
    required int pitch,
    required int timing,
    required int consistency,
    required int energy,
  }) {
    _lastBreakdown = ScoreBreakdown(
      pitch: pitch,
      timing: timing,
      consistency: consistency,
      energy: energy,
    );
    notifyListeners();
  }

  /// Clear the stored breakdown, e.g. when starting a new performance.
  void clearLastBreakdown() {
    _lastBreakdown = null;
    notifyListeners();
  }

  // ─── Board Mode ────────────────────────────────
  bool _isBoardMode = false;
  bool get isBoardMode => _isBoardMode;

  void setBoardMode(bool value) {
    _isBoardMode = value;
    notifyListeners();
  }

  // ─── Connection Status ─────────────────────────
  ConnectionStatus _connectionStatus = ConnectionStatus.connected;
  ConnectionStatus get connectionStatus => _connectionStatus;

  void setConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }

  // ─── Realtime Event Application ────────────────

  /// Apply an incoming [SyncEvent] from the event bus to local state.
  ///
  /// Called for events emitted by other clients (phones, board). Own events
  /// are filtered out upstream by the sync service.
  void applySyncEvent(SyncEvent event) {
    switch (event.type) {
      case SyncEventType.playerReady:
        final playerId = event.data['playerId'] as String?;
        final ready = event.data['ready'] as bool? ?? true;
        if (playerId != null) {
          _players = _players
              .map((p) => p.id == playerId ? p.copyWith(ready: ready) : p)
              .toList();
        }
        break;
      case SyncEventType.playerJoined:
        final id = event.data['playerId'] as String?;
        final name = event.data['name'] as String? ?? 'Player';
        if (id != null && !_players.any((p) => p.id == id)) {
          _players = [..._players, Player(id: id, name: name, level: 1)];
        }
        break;
      case SyncEventType.playerLeft:
        final id = event.data['playerId'] as String?;
        if (id != null) {
          _players = _players.where((p) => p.id != id).toList();
        }
        break;
      case SyncEventType.performanceUpdate:
        final singerId = event.data['singerId'] as String?;
        final score = (event.data['score'] as num?)?.toInt();
        if (singerId != null && score != null) {
          _players = _players
              .map((p) => p.id == singerId ? p.copyWith(score: score) : p)
              .toList();
        }
        break;
      case SyncEventType.performanceComplete:
        final singerId = event.data['singerId'] as String?;
        final score = (event.data['score'] as num?)?.toInt() ?? 0;
        if (singerId != null) {
          _players = _players
              .map((p) => p.id == singerId ? p.copyWith(score: score) : p)
              .toList();
        }
        break;
      case SyncEventType.gameStarted:
      case SyncEventType.turnAdvanced:
      case SyncEventType.songAdded:
      case SyncEventType.songRemoved:
      case SyncEventType.chatMessage:
      case SyncEventType.ping:
      case SyncEventType.pong:
        // Handled by room/player streams or not relevant to phone state.
        break;
    }
    notifyListeners();
  }
}

enum ConnectionStatus { connected, connecting, disconnected, weak }
