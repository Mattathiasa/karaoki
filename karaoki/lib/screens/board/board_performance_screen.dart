import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../widgets/lyrics.dart';
import '../../widgets/cards.dart';
import '../../widgets/ui_components.dart';

class BoardPerformanceScreen extends StatelessWidget {
  final String songTitle;
  final String artist;
  final String singerName;
  final String singerInitial;
  final String? previousLine;
  final String currentLine;
  final String? nextLine;
  final double lineProgress;
  final double progress;
  final int score;
  final int pitch;
  final int timing;
  final int combo;
  final String elapsed;
  final String duration;
  final List<QueuePill> upNext;

  const BoardPerformanceScreen({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.singerName,
    this.singerInitial = 'M',
    this.previousLine,
    required this.currentLine,
    this.nextLine,
    this.lineProgress = 0.0,
    this.progress = 0.0,
    this.score = 0,
    this.pitch = 0,
    this.timing = 0,
    this.combo = 0,
    this.elapsed = '0:00',
    this.duration = '3:42',
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
              KColors.limeTint.withOpacity(0.2),
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
                        '$artist · Pop',
                        style: KTypography.boardMono.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // LIVE pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.red.withOpacity(0.2),
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
                  // Mode pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.ink600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'CLASSIC',
                      style: KTypography.boardMono.copyWith(fontSize: 13),
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
                      '$elapsed / $duration',
                      style: KTypography.boardMono.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 16, 44, 0),
              child: KProgressBar(progress: progress, height: 5),
            ),

            // Lyrics (dominant centre)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSpacing.boardPadding * 2,
                ),
                child: KBoardLyricWidget(
                  previousLine: previousLine,
                  currentLine: currentLine,
                  nextLine: nextLine,
                  lineProgress: lineProgress,
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
                        color: KColors.limeTint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$score',
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
                            Text(
                              'PITCH $pitch%',
                              style: KTypography.boardMono.copyWith(fontSize: 13),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'TIMING $timing%',
                              style: KTypography.boardMono.copyWith(fontSize: 13),
                            ),
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
                        Text(
                          'x$combo',
                          style: const TextStyle(
                            fontFamily: 'BricolageGrotesque',
                            fontWeight: FontWeight.w800,
                            fontSize: 40,
                            color: KColors.gold,
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
                  ...upNext.map((p) => Container(
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
                      '${p.title} · ${p.requester}',
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

class QueuePill {
  final String title;
  final String requester;

  const QueuePill({required this.title, required this.requester});
}
