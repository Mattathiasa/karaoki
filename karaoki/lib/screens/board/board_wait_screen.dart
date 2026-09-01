import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/ui_components.dart';

class BoardWaitScreen extends StatelessWidget {
  final String roomName;
  final String roomCode;
  final String mode;
  final int playerCount;
  final int maxPlayers;
  final List<_BoardPlayer> players;

  const BoardWaitScreen({
    super.key,
    required this.roomName,
    required this.roomCode,
    this.mode = 'CLASSIC',
    this.playerCount = 4,
    this.maxPlayers = 8,
    this.players = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink900,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              KColors.limeTint.withOpacity(0.3),
              KColors.ink900,
            ],
          ),
        ),
        child: Row(
          children: [
            // Left column (1.15fr)
            Expanded(
              flex: 115,
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.boardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + board label
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [KColors.lime, KColors.tangerine],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🎤', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'KARAOKI BOARD',
                          style: KTypography.boardMono.copyWith(
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Room name
                    Text(
                      roomName,
                      style: const TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w700,
                        fontSize: 54,
                        color: KColors.bone,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Room code label
                    Text(
                      'ROOM CODE',
                      style: KTypography.boardMono.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Room code display
                    Text(
                      roomCode,
                      style: const TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w800,
                        fontSize: 94,
                        color: KColors.lime,
                        letterSpacing: -4,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Instruction
                    Text(
                      'Scan the QR code or enter the room code on your phone.',
                      style: KTypography.boardMono.copyWith(
                        fontSize: 16,
                        color: KColors.bone45,
                      ),
                    ),
                    const Spacer(),
                    // Meta pills
                    Row(
                      children: [
                        _BoardMetaPill(label: mode),
                        const SizedBox(width: 12),
                        _BoardMetaPill(label: 'MAX $maxPlayers PLAYERS'),
                        const SizedBox(width: 12),
                        _BoardMetaPill(label: 'PRIVATE ROOM', color: KColors.mint),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hairline separator
            Container(
              width: 1,
              color: KColors.hairline,
            ),

            // Right column (0.85fr)
            Expanded(
              flex: 85,
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.boardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // QR placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: KColors.bone,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 176,
                        height: 176,
                        decoration: BoxDecoration(
                          color: KColors.ink900,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'QR',
                          style: KTypography.boardMono.copyWith(
                            fontSize: 24,
                            color: KColors.bone28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Connected count
                    Text(
                      'CONNECTED $playerCount / $maxPlayers',
                      style: KTypography.boardMono.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // Player cards
                    Expanded(
                      child: ListView.separated(
                        itemCount: players.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = players[i];
                          return _BoardPlayerCard(
                            name: p.name,
                            initial: p.initial,
                            ready: p.ready,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardMetaPill extends StatelessWidget {
  final String label;
  final Color? color;

  const _BoardMetaPill({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: KColors.ink600,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KColors.hairline, width: 0.5),
      ),
      child: Text(
        label,
        style: KTypography.boardMono.copyWith(
          fontSize: 13,
          color: color ?? KColors.bone45,
        ),
      ),
    );
  }
}

class _BoardPlayerCard extends StatelessWidget {
  final String name;
  final String initial;
  final bool ready;

  const _BoardPlayerCard({
    required this.name,
    required this.initial,
    this.ready = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: KColors.ink650,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KColors.hairline, width: 0.5),
      ),
      child: Row(
        children: [
          KAvatar(initial: initial, size: 42),
          const SizedBox(width: 16),
          Text(
            name,
            style: KTypography.displaySection.copyWith(fontSize: 22),
          ),
          const Spacer(),
          KStatusTag(status: ready ? 'READY' : 'PICKING SONG'),
        ],
      ),
    );
  }
}

class _BoardPlayer {
  final String name;
  final String initial;
  final bool ready;

  const _BoardPlayer({
    required this.name,
    required this.initial,
    this.ready = false,
  });
}
