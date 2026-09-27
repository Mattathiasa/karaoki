import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/room.dart';
import '../models/song.dart';
import '../providers/app_state.dart';
import '../screens/board/board_countdown_screen.dart';
import '../screens/board/board_leaderboard_screen.dart';
import '../screens/board/board_performance_screen.dart';
import '../screens/board/board_queue_screen.dart';
import '../screens/board/board_reveal_screen.dart';
import '../screens/board/board_wait_screen.dart';
import '../services/realtime_sync_service.dart';
import '../services/room_service.dart';
import '../services/song_repository.dart';

/// Single room TV screen.
///
/// The board's screen is a pure function of room state (FLOWS.md §1):
/// waiting → bwait, queue/idle → bqueue, countdown → bcount,
/// performing → bperf, revealing → breveal, ranking → blead.
///
/// The phone drives the flow by writing room status through [RoomService]
/// and streaming perf.tick/perf.end events; the board never starts its own
/// playback — it mirrors [AppState], which is fed by those events.
class TvRoomScope extends StatefulWidget {
  final String? roomCode;

  const TvRoomScope({super.key, this.roomCode});

  @override
  State<TvRoomScope> createState() => _TvRoomScopeState();
}

class _TvRoomScopeState extends State<TvRoomScope> {
  StreamSubscription<Room>? _roomSub;
  StreamSubscription<List<Player>>? _playersSub;
  bool _autoJoined = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.read<AppState>();
    if (appState.currentRoom != null) {
      if (_roomSub == null) _subscribe(appState);
      return;
    }
    // Deep-linked with a code (the normal flow): adopt the room as a
    // spectator "TV" client and subscribe to its live state.
    if (!_autoJoined && widget.roomCode != null) {
      _autoJoined = true;
      _joinAsBoard(widget.roomCode!);
    }
  }

  Future<void> _joinAsBoard(String code) async {
    final appState = context.read<AppState>();
    final roomService = context.read<RoomService>();
    final sync = context.read<RealtimeSyncService>();
    try {
      // Spectate rather than join: the board must not occupy a player seat
      // or count against maxPlayers.
      final room = await roomService.roomByCode(code);
      if (room == null) return;
      appState.setRoom(room, isHost: false);
      await sync.connect(room.id, userId: appState.userId);
      if (mounted) _subscribe(appState);
    } catch (_) {
      // Room not found / not joinable — the wait screen with the entered
      // code stays up so the party host can see the code is wrong.
    }
  }

  void _subscribe(AppState appState) {
    final room = appState.currentRoom;
    if (room == null) return;
    final roomService = context.read<RoomService>();
    _roomSub = roomService.watchRoom(room.id).listen((updated) {
      if (mounted) {
        context.read<AppState>().setRoom(updated, isHost: false);
      }
    });
    _playersSub = roomService.watchPlayers(room.id).listen((players) {
      if (mounted) context.read<AppState>().updatePlayers(players);
    });
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _playersSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final room = appState.currentRoom;

    // No room yet (deep link without code, or join failed): demo wait screen.
    if (room == null) {
      return BoardWaitScreen(
        roomCode: widget.roomCode ?? 'KARA-7821',
        roomName: 'Karaoke Night',
        players: const [],
      );
    }

    final players = appState.players;
    final boardPlayers = players
        .map((p) => BoardPlayer(
              name: p.name,
              initial: p.initial,
              ready: p.ready,
            ))
        .toList();

    switch (room.status) {
      case RoomStatus.waiting:
        return BoardWaitScreen(
          roomCode: room.code,
          roomName: room.name,
          mode: room.mode.name.toUpperCase(),
          playerCount: players.length,
          maxPlayers: room.maxPlayers,
          players: boardPlayers,
        );
      case RoomStatus.queue:
        return _BoardQueueFromState(appState: appState);
      case RoomStatus.countdown:
        final entry = appState.nextUpEntry;
        if (entry == null) {
          // Countdown with nothing queued: show the queue so the host can
          // see they need to add songs from a phone.
          return _BoardQueueFromState(appState: appState);
        }
        final singer = _singerFor(appState, entry);
        return BoardCountdownScreen(
          singerName: singer?.name ?? 'Singer',
          songTitle: appState.songForEntry(entry).title,
        );
      case RoomStatus.performing:
        return const _BoardPerformanceFromState();
      case RoomStatus.revealing:
        return _BoardRevealFromState(appState: appState);
      case RoomStatus.ranking:
        return _BoardLeaderboardFromState(appState: appState);
    }
  }

  Player? _singerFor(AppState appState, QueueEntry? entry) {
    if (entry == null) return appState.currentPlayer;
    for (final p in appState.players) {
      if (p.id == entry.requestedBy) return p;
    }
    return appState.currentPlayer;
  }
}

/// Queue screen fed entirely from AppState (active entry + upcoming).
class _BoardQueueFromState extends StatelessWidget {
  final AppState appState;

  const _BoardQueueFromState({required this.appState});

  @override
  Widget build(BuildContext context) {
    final active = appState.activeEntry;
    final upcoming = appState.upcomingEntries;
    Song songFor(QueueEntry e) => appState.songForEntry(e);
    String nameFor(String id) => appState.players
        .where((p) => p.id == id)
        .map((p) => p.name)
        .firstOrNull ?? 'Guest';

    return BoardQueueScreen(
      currentTitle: active != null ? songFor(active).title : 'Add the first song',
      currentArtist: active != null ? songFor(active).artist : 'from a phone',
      singerName: active != null ? nameFor(active.requestedBy) : '—',
      singerInitial: active != null ? nameFor(active.requestedBy).isNotEmpty ? nameFor(active.requestedBy)[0].toUpperCase() : '?' : '—',
      upNext: upcoming
          .map((e) => QueueEntryBoard(
                title: songFor(e).title,
                artist: songFor(e).artist,
                requester: nameFor(e.requestedBy),
                requesterInitial: nameFor(e.requestedBy).isNotEmpty
                    ? nameFor(e.requestedBy)[0].toUpperCase()
                    : '?',
              ))
          .toList(),
    );
  }
}

/// Performance screen mirroring the singing phone: lyrics/score stream from
/// AppState — the board never runs its own playback.
class _BoardPerformanceFromState extends StatefulWidget {
  const _BoardPerformanceFromState();

  @override
  State<_BoardPerformanceFromState> createState() =>
      _BoardPerformanceFromStateState();
}

class _BoardPerformanceFromStateState extends State<_BoardPerformanceFromState> {
  @override
  void initState() {
    super.initState();
    // Load the song's lyrics so the board can render the wipe; playback
    // position comes from perf.tick progress, not from this device.
    final appState = context.read<AppState>();
    final entry = appState.nextUpEntry;
    if (entry != null) {
      unawaited(SongRepository.instance
          .byId(entry.songId)
          .then((song) => song != null ? appState.setCurrentSong(song) : null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final entry = appState.activeEntry ?? appState.nextUpEntry;
    final song = appState.currentSong ?? fixtureSongs.first;
    final singerId = entry?.requestedBy;
    final singer = appState.players
        .where((p) => p.id == singerId)
        .firstOrNull;
    final metrics = singerId != null
        ? appState.liveMetricsFor(singerId)
        : const <String, int>{};
    final score = singerId != null
        ? (appState.scoreFor(singerId) ?? 0)
        : 0;

    // Derive lyric state from the streamed progress percentage.
    final progress = (metrics['progress'] ?? 0) / 100.0;
    final lyrics = song.lyrics;
    String current = '...';
    String? previous;
    String? next;
    double lineProgress = 0;
    if (lyrics.isNotEmpty) {
      final posPercent = (progress * 100).round();
      var idx = -1;
      for (var i = lyrics.length - 1; i >= 0; i--) {
        if (posPercent >= lyrics[i].t) {
          idx = i;
          break;
        }
      }
      if (idx >= 0) {
        current = lyrics[idx].text;
        if (idx > 0) previous = lyrics[idx - 1].text;
        if (idx + 1 < lyrics.length) next = lyrics[idx + 1].text;
        final start = lyrics[idx].t;
        final end = idx + 1 < lyrics.length ? lyrics[idx + 1].t : 100;
        final span = end - start;
        lineProgress = span > 0
            ? ((posPercent - start) / span).clamp(0.0, 1.0)
            : 1.0;
      }
    }

    return BoardPerformanceScreen(
      songTitle: song.title,
      songArtist: song.artist,
      songGenre: song.genre,
      singerName: singer?.name ?? 'Singer',
      singerInitial: singer?.initial ?? '?',
      liveScore: score,
      pitch: metrics['pitch'] ?? 0,
      consistency: metrics['consistency'] ?? 0,
      speed: metrics['speed'] ?? 0,
      energy: metrics['energy'] ?? 0,
      combo: metrics['combo'] ?? 0,
      overallProgress: progress,
      positionLabel: _fmt(metrics['positionMs'] ?? 0),
      durationLabel: song.durationLabel,
      previousLine: previous,
      currentLine: current,
      nextLine: next,
      lineProgress: lineProgress,
      upNext: appState.upcomingEntries
          .take(3)
          .map((e) => appState.songForEntry(e).title)
          .toList(),
    );
  }

  String _fmt(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

/// Reveal screen from the last performanceComplete breakdown in AppState.
class _BoardRevealFromState extends StatelessWidget {
  final AppState appState;

  const _BoardRevealFromState({required this.appState});

  @override
  Widget build(BuildContext context) {
    final breakdown = appState.lastBreakdown;
    final ranked = appState.players.toList()
      ..sort((a, b) =>
          (appState.scoreFor(b.id) ?? b.score).compareTo(appState.scoreFor(a.id) ?? a.score));
    return BoardRevealScreen(
      singerName: ranked.isNotEmpty ? ranked.first.name : 'Singer',
      singerInitial: ranked.isNotEmpty ? ranked.first.initial : '?',
      score: breakdown?.overall ?? 0,
      pitch: breakdown?.pitch ?? 0,
      timing: breakdown?.timing ?? 0,
      consistency: breakdown?.consistency ?? 0,
      energy: breakdown?.energy ?? 0,
      rank: breakdown?.rank ?? 'KEEP GOING',
      rankings: ranked
          .map((p) => RankingEntry(
                name: p.name,
                initial: p.initial,
                score: appState.scoreFor(p.id) ?? p.score,
              ))
          .toList(),
    );
  }
}

/// Leaderboard screen from live player scores in AppState.
class _BoardLeaderboardFromState extends StatelessWidget {
  final AppState appState;

  const _BoardLeaderboardFromState({required this.appState});

  @override
  Widget build(BuildContext context) {
    final next = appState.nextUpEntry;
    return BoardLeaderboardScreen(
      roomName: appState.currentRoom?.name ?? 'Karaoke Night',
      performances: appState.queue.where((e) => e.state == QueueEntryState.done).length,
      mode: (appState.currentRoom?.mode.name ?? 'classic').toUpperCase(),
      nextSong: next != null ? appState.songForEntry(next).title : '',
      nextPlayer: next != null
          ? (appState.players
                  .where((p) => p.id == next.requestedBy)
                  .map((p) => p.name)
                  .firstOrNull ?? 'Guest')
          : '',
    );
  }
}
