import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

class LobbyScreen extends StatelessWidget {
  final String roomName;
  final String roomCode;
  final String hostName;
  final String mode;
  final int playerCount;
  final int maxPlayers;
  final List<LobbyPlayer> players;
  final VoidCallback? onStart;
  final VoidCallback? onBrowseSongs;

  const LobbyScreen({
    super.key,
    this.roomName = 'Friday Night Fire',
    this.roomCode = 'KARA-7821',
    this.hostName = 'Host',
    this.mode = 'CLASSIC',
    this.playerCount = 4,
    this.maxPlayers = 8,
    this.players = const [],
    this.onStart,
    this.onBrowseSongs,
  });

  @override
  Widget build(BuildContext context) {
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
                        itemCount: players.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final p = players[i];
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
                  // Browse songs + Queue
                  Row(
                    children: [
                      Expanded(
                        child: KSecondaryButton(
                          label: 'Browse songs',
                          onPressed: onBrowseSongs,
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
                  KPrimaryButton(
                    label: 'Start game',
                    onPressed: onStart,
                  ),
                  const SizedBox(height: 12),
                  // Ready up + Leave
                  Row(
                    children: [
                      Expanded(
                        child: KSecondaryButton(
                          label: 'Ready up',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KDangerButton(
                          label: 'Leave room',
                          onPressed: () {},
                        ),
                      ),
                    ],
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
