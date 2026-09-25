import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../models/room.dart';
import '../../providers/app_state.dart';
import '../../services/room_service.dart';
import '../../services/realtime_sync_service.dart';

class LobbyScreen extends StatefulWidget {
  final VoidCallback? onStart;
  final VoidCallback? onBrowseSongs;

  const LobbyScreen({
    super.key,
    this.onStart,
    this.onBrowseSongs,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _isReady = false;
  StreamSubscription<Room>? _roomSub;
  StreamSubscription<List<Player>>? _playersSub;
  bool _starting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_roomSub == null) {
      _subscribeToRoom();
    }
  }

  /// Subscribe to the live room and player streams for the current room so
  /// joins/reads/status changes from other devices show up in the lobby.
  void _subscribeToRoom() {
    final appState = context.read<AppState>();
    final room = appState.currentRoom;
    if (room == null) return;

    final sync = context.read<RealtimeSyncService>();
    // Connect this client to the room's event channel; other phones and the
    // board receive everything we emit from here.
    sync.connect(room.id, userId: appState.userId);

    final roomService = context.read<RoomService>();
    _roomSub = roomService.watchRoom(room.id).listen((updated) {
      if (mounted) appState.setRoom(updated, isHost: updated.hostId == appState.userId);
    });
    _playersSub = roomService.watchPlayers(room.id).listen((players) {
      if (mounted) appState.updatePlayers(players);
    });
  }

  Future<void> _emitEvent(String type, Map<String, dynamic> data) async {
    try {
      await context.read<RealtimeSyncService>().sendEvent(
        SyncEvent(type: type, senderId: context.read<AppState>().userId, data: data),
      );
    } catch (_) {
      // Event bus failures must never block the local game flow.
    }
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _playersSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleReady(AppState appState) async {
    final room = appState.currentRoom;
    if (room == null) return;
    final nowReady = !_isReady;
    setState(() => _isReady = nowReady);
    unawaited(_emitEvent(SyncEventType.playerReady, {
      'playerId': appState.userId,
      'ready': nowReady,
    }));
    try {
      await context.read<RoomService>().toggleReady(room.id, appState.userId);
    } catch (_) {
      // Keep the local toggle; the player stream will reconcile.
    }
  }

  Future<void> _leaveRoom(AppState appState) async {
    final roomService = context.read<RoomService>();
    final room = appState.currentRoom;
    if (room != null) {
      unawaited(_emitEvent(SyncEventType.playerLeft, {'playerId': appState.userId}));
      try {
        await roomService.leaveRoom(room.id, appState.userId);
      } catch (_) {}
      unawaited(context.read<RealtimeSyncService>().disconnect());
    }
    appState.leaveRoom();
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _startGame(AppState appState) async {
    if (_starting) return;
    setState(() => _starting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      unawaited(_emitEvent(SyncEventType.gameStarted, {
        'roomId': appState.currentRoom!.id,
        'startedBy': appState.userId,
      }));
      await context.read<RoomService>().startGame(appState.currentRoom!.id);
      if (!mounted) return;
      widget.onStart?.call();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not start the game. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final room = appState.currentRoom;
    final players = appState.players;
    final isHost = appState.isHost;

    // Use live data from AppState, fall back to demo data
    final roomName = room?.name ?? 'Friday Night Fire';
    final roomCode = room?.code ?? 'KARA-7821';
    final hostName = isHost ? appState.userName : 'Host';
    final mode = room?.mode.name.toUpperCase() ?? 'CLASSIC';
    final playerCount = players.isEmpty ? 4 : players.length;
    final maxPlayers = room?.maxPlayers ?? 8;

    // Demo players when no real data
    final displayPlayers = players.isEmpty
        ? const [
            LobbyPlayer(name: 'Makeda', initial: 'M', level: 12, ready: true, isHost: true),
            LobbyPlayer(name: 'Samuel', initial: 'S', level: 8, ready: true),
            LobbyPlayer(name: 'Hana', initial: 'H', level: 15, ready: true),
            LobbyPlayer(name: 'Daniel', initial: 'D', level: 6, ready: false),
          ]
        : players.map((p) => LobbyPlayer(
              name: p.name,
              initial: p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
              level: p.level,
              ready: p.ready,
              isHost: p.id == room?.hostId,
            )).toList();

    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Header card
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                KSpacing.mobilePaddingV,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      KColors.limeTint.withValues(alpha: 0.3),
                      KColors.tangerine.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  border: Border.all(color: KColors.hairline, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ROOM · HOST $hostName',
                          style: KTypography.monoLabel.copyWith(
                            fontSize: 9,
                            color: KColors.bone45,
                          ),
                        ),
                        const Spacer(),
                        const KIconButton(icon: Icons.settings, size: 34),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      roomName,
                      style: const TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: KColors.bone,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatPill(label: 'CODE', value: roomCode),
                        const SizedBox(width: 8),
                        _StatPill(label: 'MODE', value: mode),
                        const SizedBox(width: 8),
                        _StatPill(
                          label: 'PLAYERS',
                          value: '$playerCount/$maxPlayers',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Roster
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  20,
                  KSpacing.mobilePaddingH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLAYERS',
                      style: KTypography.monoLabel.copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: displayPlayers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final p = displayPlayers[i];
                          return KPlayerCard(
                            name: p.name,
                            initial: p.initial,
                            level: 'LV ${p.level}',
                            status: p.ready ? 'READY' : 'PICKING SONG',
                            isHost: p.isHost,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                0,
                KSpacing.mobilePaddingH,
                20,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: KSecondaryButton(
                          label: 'Browse songs',
                          onPressed: widget.onBrowseSongs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KSecondaryButton(
                          label: 'Queue',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Start game (host only)
                  if (isHost)
                    KPrimaryButton(
                      label: _starting ? 'Starting…' : 'Start game',
                      onPressed: _starting ? null : () => _startGame(appState),
                    ),
                  if (!isHost) ...[
                    KPrimaryButton(
                      label: _isReady ? 'Cancel ready' : 'Ready up',
                      onPressed: () => _toggleReady(appState),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Leave room
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: KDangerButton(
                      label: 'Leave room',
                      onPressed: () => _leaveRoom(appState),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: KColors.ink600.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(KRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: KTypography.monoLabel.copyWith(
              fontSize: 9,
              color: KColors.bone45,
            ),
          ),
          Text(
            value,
            style: KTypography.monoCode.copyWith(
              fontSize: 12,
              color: KColors.bone,
            ),
          ),
        ],
      ),
    );
  }
}

class LobbyPlayer {
  final String name;
  final String initial;
  final int level;
  final bool ready;
  final bool isHost;

  const LobbyPlayer({
    required this.name,
    required this.initial,
    this.level = 1,
    this.ready = false,
    this.isHost = false,
  });
}
