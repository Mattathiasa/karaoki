import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';
import '../models/song.dart';
import '../services/realtime_sync_service.dart';
import '../services/auth_service.dart';

/// Central app state managed by Provider
/// Holds room state, player identity, queue, and game flow
class AppState extends ChangeNotifier {
  AppState(this._auth) {
    _auth.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  final AuthService _auth;

  void _onAuthChanged() {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_userId == user.uid) {
      _isGuest = user.isAnonymous;
      return;
    }
    _userId = user.uid;
    // Anonymous sessions carry no meaningful display name ("Guest"), so
    // keep whatever name the user picked locally — otherwise the identity
    // landing after setup would clobber the name they just typed.
    if (!user.isAnonymous) {
      _userName = user.effectiveName;
    }
    _isGuest = user.isAnonymous;
    // Keep the persisted profile in sync with the authenticated identity.
    SharedPreferences.getInstance().then((p) {
      p.setString('userId', _userId);
      p.setString('userName', _userName);
    });
    notifyListeners();
  }

  // ─── User Identity ─────────────────────────────
  String _userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
  String _userName = 'Player';
  final String _userAvatar = '';
  int _userLevel = 1;
  bool _isGuest = true;

  String get userId => _userId;
  String get userName => _userName;
  String get userAvatar => _userAvatar;
  int get userLevel => _userLevel;
  bool get isGuest => _isGuest;

  /// True when the user picked a real display name. The default "Player"
  /// (or blank) counts as not set — rooms should ask for a name before
  /// letting someone join, Just Dance style.
  bool get hasCustomName {
    final name = _userName.trim();
    return name.isNotEmpty && name != 'Player';
  }

  /// Load the persisted profile (userId, name, level) from local storage.
  /// Call once at startup; userId survives restarts so rooms/identity are
  /// stable, and name/level set in onboarding are not lost.
  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getString('userId');
      if (storedId != null && storedId.isNotEmpty) {
        _userId = storedId;
      } else {
        await prefs.setString('userId', _userId);
      }
      final storedName = prefs.getString('userName');
      if (storedName != null && storedName.isNotEmpty) {
        _userName = storedName;
      }
      _userLevel = prefs.getInt('userLevel') ?? _userLevel;
      notifyListeners();
    } catch (e) {
      // Persistence unavailable (first run on a locked-down platform):
      // keep in-memory defaults rather than failing startup.
      debugPrint('AppState.loadProfile: $e');
    }
  }

  void setUserName(String name) {
    _userName = name;
    SharedPreferences.getInstance().then((p) => p.setString('userName', name));
    notifyListeners();
  }

  void setUserLevel(int level) {
    _userLevel = level;
    SharedPreferences.getInstance().then((p) => p.setInt('userLevel', level));
    notifyListeners();
  }

  /// Sync the authenticated Firebase user's identity into the profile so
  /// userId matches across devices and the display name is kept.
  void adoptFirebaseUser(User? user) {
    if (user == null) return;
    _userId = user.uid;
    final name = user.displayName;
    if (name != null && name.isNotEmpty) {
      _userName = name;
      SharedPreferences.getInstance().then((p) => p.setString('userName', name));
    }
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
    _activeEntryId = null;
    _currentSingerIndex = 0;
    _playerScores.clear();
    notifyListeners();
  }

  // ─── Queue ─────────────────────────────────────
  List<QueueEntry> _queue = [];
  List<QueueEntry> get queue => _queue;

  /// Songs resolved by id for rendering queue entries. Populated when
  /// entries are added locally; fixture songs fill any gaps.
  final Map<String, Song> _queueSongs = {};
  Song songForEntry(QueueEntry entry) {
    final song = _queueSongs[entry.songId];
    if (song != null) return song;
    return fixtureSongs.firstWhere(
      (s) => s.id == entry.songId,
      orElse: () => fixtureSongs.first,
    );
  }

  void updateQueue(List<QueueEntry> entries) {
    _queue = entries;
    notifyListeners();
  }

  /// Append a song to the local queue view. The RoomService/realtime call
  /// happens in the screen; this mirrors the result so the UI updates
  /// immediately and offline (stub mode) still works.
  void addToQueue(QueueEntry entry, Song song) {
    _queue = [..._queue, entry];
    _queueSongs[entry.songId] = song;
    notifyListeners();
  }

  /// Remove a queue entry locally, e.g. after a successful service call.
  void removeFromQueue(String entryId) {
    _queue = _queue.where((e) => e.entryId != entryId).toList();
    notifyListeners();
  }

  // ─── Game Flow ─────────────────────────────────
  int _currentSingerIndex = 0;
  int get currentSingerIndex => _currentSingerIndex;

  /// Id of the queue entry being performed right now (or null between
  /// songs). Drives the turn loop: the singer is this entry's requester and
  /// [advanceQueue] marks it done and selects the next entry.
  String? _activeEntryId;
  String? get activeEntryId => _activeEntryId;

  /// The queue entry currently being performed.
  QueueEntry? get activeEntry {
    if (_activeEntryId == null) return null;
    for (final e in _queue) {
      if (e.entryId == _activeEntryId) return e;
    }
    return null;
  }

  /// Next entry to perform: the active one, otherwise the first still-
  /// queued entry, in position order.
  QueueEntry? get nextUpEntry {
    final active = activeEntry;
    if (active != null) return active;
    final queued = _queue
        .where((e) => e.state == QueueEntryState.queued)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return queued.isEmpty ? null : queued.first;
  }

  /// Songs still waiting to be performed (excludes the active one), in
  /// position order — feeds the board's UP NEXT rail and the lobby's
  /// "who is after me" hints.
  List<QueueEntry> get upcomingEntries {
    final activeId = _activeEntryId;
    final upcoming = _queue
        .where((e) =>
            e.state == QueueEntryState.queued && e.entryId != activeId)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return upcoming;
  }

  /// Mark [entryId] as the entry being performed.
  void setActiveEntry(String? entryId) {
    _activeEntryId = entryId;
    if (entryId != null) {
      _queue = _queue
          .map((e) => e.entryId == entryId
              ? e.copyWith(state: QueueEntryState.playing)
              : e)
          .toList();
    }
    notifyListeners();
  }

  /// Advance the turn: mark the current entry done and promote the next
  /// queued entry to playing. Returns the new active entry, or null when
  /// the queue is finished.
  QueueEntry? advanceQueue() {
    _queue = _queue
        .map((e) => e.entryId == _activeEntryId
            ? e.copyWith(state: QueueEntryState.done)
            : e)
        .toList();
    _activeEntryId = null;
    final next = nextUpEntry;
    if (next != null) {
      setActiveEntry(next.entryId);
    } else {
      notifyListeners();
    }
    return next;
  }

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

  /// Live/final score per singer id, fed by performanceUpdate and
  /// performanceComplete sync events. Lets the board leaderboard and the
  /// lobby show "how is everyone doing" without touching the players list.
  final Map<String, int> _playerScores = {};
  Map<String, int> get playerScores => Map.unmodifiable(_playerScores);

  /// Score for one player, or null when nothing has arrived yet.
  int? scoreFor(String playerId) => _playerScores[playerId];

  /// Reset all live scores (start of a new performance or new game).
  void clearLiveScores() {
    _playerScores.clear();
    _liveMetrics.clear();
    notifyListeners();
  }

  /// Latest live metrics (pitch/timing/consistency/energy/speed/combo/
  /// progress) per singer, fed by perf.tick (performanceUpdate) events.
  /// The board reads these to mirror the singing phone between full ticks.
  final Map<String, Map<String, int>> _liveMetrics = {};
  Map<String, int> liveMetricsFor(String singerId) =>
      Map.unmodifiable(_liveMetrics[singerId] ?? const {});

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
    int speed = 0,
  }) {
    _lastBreakdown = ScoreBreakdown(
      pitch: pitch,
      timing: timing,
      consistency: consistency,
      energy: energy,
      speed: speed,
    );
    notifyListeners();
  }

  /// Clear the stored breakdown, e.g. when starting a new performance.
  void clearLastBreakdown() {
    _lastBreakdown = null;
    notifyListeners();
  }

  // ─── Auth passthrough ──────────────────────────
  AuthService get auth => _auth;

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
        } else if (id != null) {
          // Already known: refresh the name in case it changed.
          _players = _players
              .map((p) => p.id == id ? p.copyWith(name: name) : p)
              .toList();
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
          _playerScores[singerId] = score;
          _players = _players
              .map((p) => p.id == singerId ? p.copyWith(score: score) : p)
              .toList();
          _liveMetrics[singerId] = {
            for (final entry in event.data.entries)
              if (entry.value is num) entry.key: (entry.value as num).toInt(),
          };
        }
        break;
      case SyncEventType.performanceComplete:
        final singerId = event.data['singerId'] as String?;
        final score = (event.data['score'] as num?)?.toInt() ?? 0;
        if (singerId != null) {
          _playerScores[singerId] = score;
          _players = _players
              .map((p) => p.id == singerId ? p.copyWith(score: score) : p)
              .toList();
          // Carry the final breakdown over for screens that render the
          // result of the remote performance (board reveal, room history).
          _lastBreakdown = ScoreBreakdown(
            pitch: (event.data['pitch'] as num?)?.toInt() ?? 0,
            timing: (event.data['timing'] as num?)?.toInt() ?? 0,
            consistency: (event.data['consistency'] as num?)?.toInt() ?? 0,
            energy: (event.data['energy'] as num?)?.toInt() ?? 0,
            speed: (event.data['speed'] as num?)?.toInt() ?? 0,
          );
        }
        break;
      case SyncEventType.songAdded:
        final songId = event.data['songId'] as String?;
        final requester =
            event.data['requestedBy'] as String? ?? event.senderId;
        if (songId != null) {
          final entryId =
              'entry-$songId-$requester-${event.timestamp.millisecondsSinceEpoch}';
          if (!_queue.any(
              (e) => e.songId == songId && e.requestedBy == requester)) {
            _queue = [
              ..._queue,
              QueueEntry(
                entryId: entryId,
                songId: songId,
                requestedBy: requester,
                position: _queue.length + 1,
              ),
            ];
          }
        }
        break;
      case SyncEventType.songRemoved:
        final removedId = event.data['entryId'] as String?;
        if (removedId != null) {
          _queue = _queue.where((e) => e.entryId != removedId).toList();
        }
        break;
      case SyncEventType.gameStarted:
      case SyncEventType.turnAdvanced:
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
