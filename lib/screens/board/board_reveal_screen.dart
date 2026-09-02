import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/cards.dart';

class BoardRevealScreen extends StatelessWidget {
  final String singerName;
  final String singerInitial;
  final int score;
  final int pitch;
  final int timing;
  final int consistency;
  final int energy;
  final String rank;
  final String songTitle;
  final bool isNewRecord;
  final List<RankingEntry> rankings;

  const BoardRevealScreen({
    super.key,
    this.singerName = 'Matt',
    this.singerInitial = 'M',
    this.score = 87,
    this.pitch = 92,
    this.timing = 88,
    this.consistency = 81,
    this.energy = 95,
    this.rank = 'SUPERSTAR',
    this.songTitle = 'Neon Midnight',
    this.isNewRecord = false,
    this.rankings = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink900,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.5,
            colors: [
              KColors.gold.withOpacity(0.15),
              KColors.ink900,
            ],
          ),
        ),
        child: Row(
          children: [
            // Left: score reveal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.boardPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    KAvatar(initial: singerInitial, size: 120),
                    const SizedBox(height: 24),
                    // Name
                    Text(
                      singerName,
                      style: const TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w700,
                        fontSize: 66,
                        color: KColors.bone,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // FINAL SCORE
                    Text(
                      'FINAL SCORE',
                      style: KTypography.boardMono.copyWith(
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Score display
                    Text(
                      '$score',
                      style: TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w800,
                        fontSize: 206,
                        color: KColors.gold,
                        letterSpacing: -9,
                        height: 1.0,
                        shadows: [
                          BoxShadow(
                            color: KColors.gold.withOpacity(0.5),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rank pill                     KRankBadge(rank: rank),
                    if (isNewRecord) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: KColors.mint.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(KRadius.pill),
                        ),
                        child: Text(
                          '★ NEW ROOM RECORD FOR $songTitle',
                          style: KTypography.boardMono.copyWith(
                            fontSize: 13,
                            color: KColors.mint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Hairline separator
            Container(width: 1, color: KColors.hairline),

            // Right: breakdown + ranking
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.boardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BREAKDOWN',
                      style: KTypography.boardMono.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    _BreakdownRow(label: 'PITCH', value: pitch, color: KColors.mint),
                    const SizedBox(height: 14),
                    _BreakdownRow(label: 'TIMING', value: timing, color: KColors.gold),
                    const SizedBox(height: 14),
                    _BreakdownRow(label: 'CONSISTENCY', value: consistency, color: KColors.teal),
                    const SizedBox(height: 14),
                    _BreakdownRow(label: 'ENERGY', value: energy, color: KColors.lime),
                    const SizedBox(height: 32),
                    // Room ranking
                    Text(
                      'ROOM RANKING',
                      style: KTypography.boardMono.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: rankings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final r = rankings[i];
                          return _RankingRow(
                            rank: i + 1,
                            name: r.name,
                            initial: r.initial,
                            score: r.score,
                            isCurrent: i == 0,
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

class _BreakdownRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: KTypography.boardMono.copyWith(fontSize: 14),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontFamily: 'BricolageGrotesque',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: KColors.ink600,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int rank;
  final String name;
  final String initial;
  final int score;
  final bool isCurrent;

  const _RankingRow({
    required this.rank,
    required this.name,
    required this.initial,
    required this.score,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? KColors.limeTint.withOpacity(0.2) : KColors.ink650,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? KColors.limeTint : KColors.hairline,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: KTypography.boardMono.copyWith(
              fontSize: 16,
              color: KColors.bone28,
            ),
          ),
          const SizedBox(width: 12),
          KAvatar(initial: initial, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'BricolageGrotesque',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: KColors.bone,
              ),
            ),
          ),
          Text(
            score.toString(),
            style: const TextStyle(
              fontFamily: 'BricolageGrotesque',
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: KColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class RankingEntry {
  final String name;
  final String initial;
  final int score;

  const RankingEntry({
    required this.name,
    required this.initial,
    required this.score,
  });
}
