import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../models/song.dart';

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

  void setCurrentSong(Song song) {
    _currentSong = song;
    notifyListeners();
  }

  void updateLiveScore(int score) {
    _liveScore = score;
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
}

enum ConnectionStatus { connected, connecting, disconnected, weak }
