import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../widgets/cards.dart';
import '../../widgets/lyrics.dart';
import '../../widgets/ui_components.dart';

/// Board/TV performance screen — shows large lyrics, pitch gauge, score, combo.
///
/// The board never runs its own playback: every value is streamed from the
/// singing phone via perf.tick (performanceUpdate) events into [AppState],
/// and passed in here by [TvRoomScope]. This keeps one clock and one score
/// authority (the phone + server), exactly as FLOWS.md §3 requires.
class BoardPerformanceScreen extends StatelessWidget {
  final String songTitle;
  final String songArtist;
  final String songGenre;
  final String singerName;
  final String singerInitial;
  final int liveScore;
  final int pitch;
  final int consistency;
  final int speed;
  final int energy;
  final int combo;
  final double overallProgress;
  final String positionLabel;
  final String durationLabel;
  final String? previousLine;
  final String currentLine;
  final String? nextLine;
  final double lineProgress;
  final List<String> upNext;

  const BoardPerformanceScreen({
    super.key,
    this.songTitle = '',
    this.songArtist = '',
    this.songGenre = '',
    this.singerName = 'Singer',
    this.singerInitial = '?',
    this.liveScore = 0,
    this.pitch = 0,
    this.consistency = 0,
    this.speed = 0,
    this.energy = 0,
    this.combo = 0,
    this.overallProgress = 0,
    this.positionLabel = '0:00',
    this.durationLabel = '0:00',
    this.previousLine,
    this.currentLine = '',
    this.nextLine,
    this.lineProgress = 0,
    this.upNext = const [],
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
              KColors.limeTint.withValues(alpha: 0.2),
              KColors.ink900,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.boardPadding,
                24,
                KSpacing.boardPadding,
                0,
              ),
              child: Row(
                children: [
                  // Cover art
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [KColors.limeTint, KColors.ink700],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.music_note, color: KColors.bone28, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Song info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songTitle,
                        style: const TextStyle(
                          fontFamily: 'BricolageGrotesque',
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                          color: KColors.bone,
                        ),
                      ),
                      Text(
                        songGenre.isEmpty
                            ? songArtist
                            : '$songArtist \u00b7 $songGenre',
                        style: KTypography.boardMono.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // LIVE pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const KLiveDot(color: KColors.red, size: 6),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: KTypography.boardMono.copyWith(
                            fontSize: 13,
                            color: KColors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.ink600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$positionLabel / $durationLabel',
                      style: KTypography.boardMono.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 16, 44, 0),
              child: KProgressBar(progress: overallProgress.clamp(0.0, 1.0), height: 5),
            ),

            // Lyrics (dominant centre)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSpacing.boardPadding * 2,
                ),
                child: currentLine.isNotEmpty
                    ? KBoardLyricWidget(
                        previousLine: previousLine,
                        currentLine: currentLine,
                        nextLine: nextLine,
                        lineProgress: lineProgress,
                      )
                    : const Center(
                        child: Text(
                          '...',
                          style: TextStyle(
                            fontFamily: 'BricolageGrotesque',
                            fontSize: 64,
                            color: KColors.bone28,
                          ),
                        ),
                      ),
              ),
            ),

            // Bottom rail (4 columns)
            Container(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.boardPadding,
                16,
                KSpacing.boardPadding,
                0,
              ),
              child: Row(
                children: [
                  // Now singing
                  _BottomColumn(
                    label: '01 / NOW SINGING',
                    child: Row(
                      children: [
                        KAvatar(initial: singerInitial, size: 50),
                        const SizedBox(width: 12),
                        Text(
                          singerName,
                          style: const TextStyle(
                            fontFamily: 'BricolageGrotesque',
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                            color: KColors.bone,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Live score
                  _BottomColumn(
                    label: '02 / LIVE SCORE',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: KColors.limeTint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // Counts toward each perf.tick value so the board
                      // score glides instead of jumping every 2 seconds.
                      child: KCountUpText(
                        liveScore,
                        duration: const Duration(milliseconds: 700),
                        style: const TextStyle(
                          fontFamily: 'BricolageGrotesque',
                          fontWeight: FontWeight.w800,
                          fontSize: 44,
                          color: KColors.lime,
                        ),
                      ),
                    ),
                  ),
                  // Pitch track
                  _BottomColumn(
                    label: '03 / PITCH TRACK',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            KCountUpText(pitch, prefix: 'PITCH ', suffix: '%', duration: const Duration(milliseconds: 500), style: KTypography.boardMono.copyWith(fontSize: 13)),
                            const SizedBox(width: 16),
                            KCountUpText(consistency, prefix: 'CONSISTENCY ', suffix: '%', duration: const Duration(milliseconds: 500), style: KTypography.boardMono.copyWith(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            KCountUpText(speed, prefix: 'SPEED ', suffix: '%', duration: const Duration(milliseconds: 500), style: KTypography.boardMono.copyWith(fontSize: 13)),
                            const SizedBox(width: 16),
                            KCountUpText(energy, prefix: 'ENERGY ', suffix: '%', duration: const Duration(milliseconds: 500), style: KTypography.boardMono.copyWith(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          height: 50,
                          child: KEqualiser(height: 50, barCount: 18),
                        ),
                      ],
                    ),
                  ),
                  // Combo
                  _BottomColumn(
                    label: '04 / COMBO',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.whatshot, color: KColors.gold, size: 34),
                        const SizedBox(width: 8),
                        // Pops on each combo bump; steady while the streak
                        // holds.
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: Text(
                            'x$combo',
                            key: ValueKey(combo),
                            style: const TextStyle(
                              fontFamily: 'BricolageGrotesque',
                              fontWeight: FontWeight.w800,
                              fontSize: 40,
                              color: KColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer: up next
            Container(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.boardPadding,
                12,
                KSpacing.boardPadding,
                24,
              ),
              child: Row(
                children: [
                  Text(
                    'UP NEXT',
                    style: KTypography.boardMono.copyWith(fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  ...upNext.map((title) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: KColors.ink600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      title,
                      style: KTypography.boardMono.copyWith(fontSize: 12),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomColumn extends StatelessWidget {
  final String label;
  final Widget child;

  const _BottomColumn({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: KTypography.boardMono.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
