import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/lyrics.dart';
import '../../widgets/ui_components.dart';

class SingingScreen extends StatelessWidget {
  final String? previousLine;
  final String currentLine;
  final String? nextLine;
  final double lineProgress;
  final double progress;
  final int pitch;
  final int timing;
  final int combo;
  final int score;
  final String elapsed;
  final String duration;

  const SingingScreen({
    super.key,
    this.previousLine,
    required this.currentLine,
    this.nextLine,
    this.lineProgress = 0.0,
    this.progress = 0.0,
    this.pitch = 0,
    this.timing = 0,
    this.combo = 0,
    this.score = 0,
    this.elapsed = '0:00',
    this.duration = '3:42',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Top: singing status bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                KSpacing.mobilePaddingV,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Row(
                children: [
                  // Red pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(KRadius.pill),
                    ),
                    child: Row(
                      children: [
                        KLiveDot(color: KColors.red, size: 6),
                        const SizedBox(width: 6),
                        Text(
                          'YOU ARE SINGING',
                          style: KTypography.monoLabel.copyWith(
                            fontSize: 9,
                            color: KColors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const KIconButton(icon: Icons.pause, size: 34),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                12,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    elapsed,
                    style: KTypography.monoLabel.copyWith(
                      fontSize: 10,
                      color: KColors.bone45,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KProgressBar(progress: progress, height: 5),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    duration,
                    style: KTypography.monoLabel.copyWith(
                      fontSize: 10,
                      color: KColors.bone45,
                    ),
                  ),
                ],
              ),
            ),

            // Lyrics (dominant centre)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSpacing.massive,
                ),
                child: KLyricWidget(
                  previousLine: previousLine,
                  currentLine: currentLine,
                  nextLine: nextLine,
                  lineProgress: lineProgress,
                ),
              ),
            ),

            // Input equaliser
            const SizedBox(
              height: 52,
              child: KEqualiser(height: 52, barCount: 18),
            ),

            // Metrics
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                12,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Row(
                children: [
                  _MetricCard(
                    label: 'PITCH',
                    value: '$pitch%',
                    color: KColors.mint,
                  ),
                  const SizedBox(width: 8),
                  _MetricCard(
                    label: 'TIMING',
                    value: '$timing%',
                    color: KColors.gold,
                  ),
                  const SizedBox(width: 8),
                  _MetricCard(
                    label: '🔥 COMBO',
                    value: 'x$combo',
                    color: KColors.lime,
                  ),
                ],
              ),
            ),

            // Live score
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                10,
                KSpacing.mobilePaddingH,
                12,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: KColors.limeTint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(KRadius.tile),
                  border: Border.all(
                    color: KColors.limeTint.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LIVE SCORE',
                      style: KTypography.monoLabel.copyWith(
                        fontSize: 9,
                        color: KColors.bone45,
                      ),
                    ),
                    Text(
                      '$score',
                      style: KTypography.displayHeadline2.copyWith(
                        fontSize: 26,
                        color: KColors.lime,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // End performance link
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'End performance →',
                  style: KTypography.uiButton.copyWith(
                    color: KColors.bone55,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KRadius.tile),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: KTypography.monoLabel.copyWith(
                fontSize: 9,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: KTypography.displayHeadline2.copyWith(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
