import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../providers/app_state.dart';

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
                      KColors.limeTint.withOpacity(0.3),
                      KColors.tangerine.withOpacity(0.1),
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
                      label: 'Start game',
                      onPressed: widget.onStart,
                    ),
                  if (!isHost) ...[
                    KPrimaryButton(
                      label: _isReady ? 'Cancel ready' : 'Ready up',
                      onPressed: () => setState(() => _isReady = !_isReady),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Leave room
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: KDangerButton(
                      label: 'Leave room',
                      onPressed: () {
                        appState.leaveRoom();
                        Navigator.of(context).maybePop();
                      },
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
        color: KColors.ink600.withOpacity(0.6),
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
