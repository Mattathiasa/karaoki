import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../widgets/cards.dart';
import '../../providers/app_state.dart';

class BoardLeaderboardScreen extends StatelessWidget {
  final String roomName;
  final int performances;
  final String mode;
  final List<BoardLeaderboardEntry> entries;
  final String nextSong;
  final String nextPlayer;

  const BoardLeaderboardScreen({
    super.key,
    this.roomName = 'Friday Night Fire',
    this.performances = 6,
    this.mode = 'CLASSIC',
    this.entries = const [],
    this.nextSong = '',
    this.nextPlayer = '',
  });

  @override
  Widget build(BuildContext context) {
    // Prefer live player scores from AppState (fed by performanceUpdate and
    // performanceComplete events); fall back to constructor entries.
    final appState = context.watch<AppState>();
    final liveEntries = appState.players
        .map((p) => BoardLeaderboardEntry(
              name: p.name,
              initial: p.initial,
              score: appState.scoreFor(p.id) ?? p.score,
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final effectiveEntries = liveEntries.isNotEmpty ? liveEntries : entries;

    return Scaffold(
      backgroundColor: KColors.ink900,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.5,
            colors: [KColors.gold.withValues(alpha: 0.12), KColors.ink900],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.boardPadding, 24, KSpacing.boardPadding, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ROOM LEADERBOARD', style: KTypography.boardMono.copyWith(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          roomName,
                          style: const TextStyle(
                            fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                            fontSize: 46, color: KColors.bone, letterSpacing: -2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'AFTER $performances PERFORMANCES \u00b7 $mode',
                    style: KTypography.boardMono.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),

            // Podium
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KSpacing.boardPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 2nd
                    if (effectiveEntries.length > 1)
                      _BoardPodiumColumn(
                        rank: 2, initial: effectiveEntries[1].initial, name: effectiveEntries[1].name,
                        score: effectiveEntries[1].score, height: 196, avatarSize: 96,
                      ),
                    const SizedBox(width: 32),
                    // 1st
                    if (effectiveEntries.isNotEmpty)
                      _BoardPodiumColumn(
                        rank: 1, initial: effectiveEntries[0].initial, name: effectiveEntries[0].name,
                        score: effectiveEntries[0].score, height: 290, avatarSize: 120,
                        showCrown: true,
                      ),
                    const SizedBox(width: 32),
                    // 3rd
                    if (effectiveEntries.length > 2)
                      _BoardPodiumColumn(
                        rank: 3, initial: effectiveEntries[2].initial, name: effectiveEntries[2].name,
                        score: effectiveEntries[2].score, height: 148, avatarSize: 80,
                      ),
                  ],
                ),
              ),
            ),

            // Footer: 4th place + next up
            Container(
              padding: const EdgeInsets.fromLTRB(KSpacing.boardPadding, 16, KSpacing.boardPadding, 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: KColors.hairline, width: 0.5)),
              ),
              child: Row(
                children: [
                  if (effectiveEntries.length > 3)
                    Expanded(
                      child: Row(
                        children: [
                          Text('4', style: KTypography.boardMono.copyWith(fontSize: 16, color: KColors.bone28)),
                          const SizedBox(width: 12),
                          KAvatar(initial: effectiveEntries[3].initial, size: 36),
                          const SizedBox(width: 12),
                          Text(effectiveEntries[3].name, style: const TextStyle(
                            fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                            fontSize: 22, color: KColors.bone,
                          )),
                          const SizedBox(width: 16),
                          Text('${effectiveEntries[3].score}', style: const TextStyle(
                            fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
                            fontSize: 26, color: KColors.gold,
                          )),
                        ],
                      ),
                    ),
                  if (nextSong.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: KColors.ink600,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: KColors.hairline, width: 0.5),
                      ),
                      child: Text(
                        'Next up: $nextSong - $nextPlayer',
                        style: KTypography.boardMono.copyWith(fontSize: 12),
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

class _BoardPodiumColumn extends StatelessWidget {
  final int rank;
  final String initial;
  final String name;
  final int score;
  final double height;
  final double avatarSize;
  final bool showCrown;

  const _BoardPodiumColumn({
    required this.rank, required this.initial, required this.name,
    required this.score, required this.height, required this.avatarSize,
    this.showCrown = false,
  });

  Color get _color => rank == 1 ? KColors.gold : KColors.bone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showCrown) ...[
          const Text('👑', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 12),
        ],
        KAvatar(initial: initial, size: avatarSize),
        const SizedBox(height: 12),
        Text(name, style: TextStyle(
          fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
          fontSize: rank == 1 ? 40 : 26, color: _color,
        )),
        const SizedBox(height: 8),
        Text(rank == 1 ? '1ST' : rank == 2 ? '2ND' : '3RD',
          style: KTypography.boardMono.copyWith(fontSize: 14, color: _color),
        ),
        const SizedBox(height: 4),
        Text('$score', style: KTypography.boardMono.copyWith(fontSize: 14, color: _color)),
        if (rank == 1) ...[
          const SizedBox(height: 8),           const KRankBadge(rank: 'SUPERSTAR'),
        ],
        const SizedBox(height: 12),
        Container(
          width: 160, height: height,
          decoration: BoxDecoration(
            color: rank == 1 ? KColors.gold.withValues(alpha: 0.3) : KColors.ink600,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: rank == 1 ? KColors.gold.withValues(alpha: 0.5) : KColors.hairline,
              width: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class BoardLeaderboardEntry {
  final String name;
  final String initial;
  final int score;
  const BoardLeaderboardEntry({required this.name, required this.initial, required this.score});
}
