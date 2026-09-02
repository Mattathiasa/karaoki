enum RoomStatus { waiting, queue, countdown, performing, revealing, ranking }
enum GameMode { classic, battle, team, duet, passTheMic }

RoomStatus roomStatusFromString(String s) => RoomStatus.values.firstWhere(
  (e) => e.name == s,
  orElse: () => RoomStatus.waiting,
);

GameMode gameModeFromString(String s) => GameMode.values.firstWhere(
  (e) => e.name == s,
  orElse: () => GameMode.classic,
);

QueueEntryState queueEntryStateFromString(String s) => QueueEntryState.values.firstWhere(
  (e) => e.name == s,
  orElse: () => QueueEntryState.queued,
);

class Room {
  final String id;
  final String code;
  final String name;
  final String hostId;
  final GameMode mode;
  final int maxPlayers;
  final String visibility;
  final String category;
  final String difficulty;
  final RoomStatus status;

  const Room({
    required this.id,
    required this.code,
    required this.name,
    required this.hostId,
    this.mode = GameMode.classic,
    this.maxPlayers = 8,
    this.visibility = 'Private',
    this.category = 'Party',
    this.difficulty = 'Mixed',
    this.status = RoomStatus.waiting,
  });

  Room copyWith({
    RoomStatus? status,
    GameMode? mode,
    String? name,
    int? maxPlayers,
    String? hostId,
  }) {
    return Room(
      id: id,
      code: code,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      mode: mode ?? this.mode,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      visibility: visibility,
      category: category,
      difficulty: difficulty,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'hostId': hostId,
    'mode': mode.name,
    'maxPlayers': maxPlayers,
    'visibility': visibility,
    'category': category,
    'difficulty': difficulty,
    'status': status.name,
  };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    hostId: json['hostId'] as String,
    mode: gameModeFromString(json['mode'] as String? ?? 'classic'),
    maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 8,
    visibility: json['visibility'] as String? ?? 'Private',
    category: json['category'] as String? ?? 'Party',
    difficulty: json['difficulty'] as String? ?? 'Mixed',
    status: roomStatusFromString(json['status'] as String? ?? 'waiting'),
  );
}

class Player {
  final String id;
  final String name;
  final String? avatarUrl;
  final int level;
  final bool ready;
  final bool connected;
  final String? team;
  final int score;

  const Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.level = 1,
    this.ready = false,
    this.connected = true,
    this.team,
    this.score = 0,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  String get statusTag {
    if (!connected) return 'DISCONNECTED';
    if (ready) return 'READY';
    return 'PICKING SONG';
  }

  String get levelLabel => 'LV $level';

  Player copyWith({
    String? name,
    int? level,
    bool? ready,
    bool? connected,
    int? score,
    String? team,
    String? avatarUrl,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      ready: ready ?? this.ready,
      connected: connected ?? this.connected,
      team: team ?? this.team,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'level': level,
    'ready': ready,
    'connected': connected,
    'team': team,
    'score': score,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    level: (json['level'] as num?)?.toInt() ?? 1,
    ready: json['ready'] as bool? ?? false,
    connected: json['connected'] as bool? ?? true,
    team: json['team'] as String?,
    score: (json['score'] as num?)?.toInt() ?? 0,
  );
}

class QueueEntry {
  final String entryId;
  final String songId;
  final String requestedBy;
  final int position;
  final QueueEntryState state;

  const QueueEntry({
    required this.entryId,
    required this.songId,
    required this.requestedBy,
    required this.position,
    this.state = QueueEntryState.queued,
  });

  Map<String, dynamic> toJson() => {
    'entryId': entryId,
    'songId': songId,
    'requestedBy': requestedBy,
    'position': position,
    'state': state.name,
  };

  factory QueueEntry.fromJson(Map<String, dynamic> json) => QueueEntry(
    entryId: json['entryId'] as String,
    songId: json['songId'] as String,
    requestedBy: json['requestedBy'] as String,
    position: (json['position'] as num).toInt(),
    state: queueEntryStateFromString(json['state'] as String? ?? 'queued'),
  );
}

enum QueueEntryState { queued, playing, done, skipped }

class Performance {
  final String songId;
  final String singerId;
  final DateTime startedAt;
  final Duration duration;
  final double positionMs;
  final int score;

  const Performance({
    required this.songId,
    required this.singerId,
    required this.startedAt,
    required this.duration,
    this.positionMs = 0,
    this.score = 0,
  });

  double get progress => duration.inMilliseconds > 0
      ? positionMs / duration.inMilliseconds
      : 0.0;

  int get currentLineIndex => 0;
  double get lineProgress => 0.0;
}

class ScoreBreakdown {
  final int pitch;
  final int timing;
  final int consistency;
  final int energy;

  const ScoreBreakdown({
    required this.pitch,
    required this.timing,
    required this.consistency,
    required this.energy,
  });

  int get overall => ((pitch * 0.4) + (timing * 0.3) + (consistency * 0.15) + (energy * 0.15)).round();

  String get rank {
    if (overall >= 90) return 'SUPERSTAR';
    if (overall >= 75) return 'GREAT';
    if (overall >= 60) return 'SOLID';
    return 'KEEP GOING';
  }

  String get rankEmoji {
    switch (rank) {
      case 'SUPERSTAR': return '';
      case 'GREAT': return '';
      case 'SOLID': return '';
      default: return '';
    }
  }
}
