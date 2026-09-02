import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

class CompleteScreen extends StatelessWidget {
  final int score;
  final int pitch;
  final int timing;
  final int consistency;
  final int energy;
  final bool isNewBest;
  final int previousBest;
  final VoidCallback? onContinue;
  final VoidCallback? onLeaderboard;

  const CompleteScreen({
    super.key,
    this.score = 87,
    this.pitch = 92,
    this.timing = 88,
    this.consistency = 81,
    this.energy = 95,
    this.isNewBest = true,
    this.previousBest = 87,
    this.onContinue,
    this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: KSpacing.mobilePaddingH,
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Score
              KScoreBadge(score: score),
              const SizedBox(height: 12),
              // Rank
              const KRankBadge(rank: 'SUPERSTAR'),
              const SizedBox(height: 12),
              // Personal best
              if (isNewBest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: KColors.mint.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(KRadius.pill),
                  ),
                  child: Text(
                    '★ NEW PERSONAL BEST · +${score - previousBest} FROM LAST TIME',
                    style: KTypography.monoLabel.copyWith(
                      fontSize: 9,
                      color: KColors.mint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              // Breakdown
              _BreakdownBar(label: 'PITCH', value: pitch, color: KColors.mint),
              const SizedBox(height: 10),
              _BreakdownBar(label: 'TIMING', value: timing, color: KColors.gold),
              const SizedBox(height: 10),
              _BreakdownBar(
                label: 'CONSISTENCY',
                value: consistency,
                color: KColors.teal,
              ),
              const SizedBox(height: 10),
              _BreakdownBar(label: 'ENERGY', value: energy, color: KColors.lime),
              const SizedBox(height: 32),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: KSecondaryButton(
                      label: 'Share',
                      icon: const Icon(Icons.share, color: KColors.bone, size: 16),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KSecondaryButton(
                      label: 'Save',
                      icon: const Icon(Icons.save, color: KColors.bone, size: 16),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              KPrimaryButton(
                label: 'See the leaderboard',
                onPressed: onLeaderboard,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onContinue,
                child: Text(
                  'Continue singing',
                  style: KTypography.uiButton.copyWith(
                    color: KColors.bone55,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _BreakdownBar({
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
              style: KTypography.monoLabel.copyWith(
                fontSize: 9,
                color: KColors.bone45,
              ),
            ),
            Text(
              '$value%',
              style: KTypography.uiRowTitle.copyWith(
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
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
                    blurRadius: 8,
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
