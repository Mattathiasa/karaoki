enum RoomStatus { waiting, queue, countdown, performing, revealing, ranking }
enum GameMode { classic, battle, team, duet, passTheMic }

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
  }) {
    return Room(
      id: id,
      code: code,
      name: name,
      hostId: hostId,
      mode: mode ?? this.mode,
      maxPlayers: maxPlayers,
      visibility: visibility,
      category: category,
      difficulty: difficulty,
      status: status ?? this.status,
    );
  }
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
      case 'SUPERSTAR': return '🔥';
      case 'GREAT': return '⭐';
      case 'SOLID': return '👍';
      default: return '';
    }
  }
}
