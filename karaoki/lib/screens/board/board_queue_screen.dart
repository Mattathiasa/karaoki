import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/cards.dart';
import '../../widgets/ui_components.dart';

class BoardQueueScreen extends StatelessWidget {
  final String currentTitle;
  final String currentArtist;
  final String singerName;
  final String singerInitial;
  final String elapsed;
  final String duration;
  final double progress;
  final List<_QueueEntry> upNext;

  const BoardQueueScreen({
    super.key,
    required this.currentTitle,
    required this.currentArtist,
    required this.singerName,
    this.singerInitial = 'M',
    this.elapsed = '1:32',
    this.duration = '3:42',
    this.progress = 0.42,
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
            colors: [KColors.limeTint.withOpacity(0.2), KColors.ink900],
          ),
        ),
        child: Row(
          children: [
            // Left: Now playing
            Expanded(
              flex: 115,
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.boardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOW PLAYING',
                      style: KTypography.boardMono.copyWith(
                        fontSize: 14,
                        color: KColors.lime,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Cover art
                    Container(
                      width: 196,
                      height: 196,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(KRadius.heroCard),
                        gradient: const LinearGradient(
                          colors: [KColors.limeTint, KColors.ink700],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.music_note, color: KColors.bone28, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentTitle,
                      style: const TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w700,
                        fontSize: 48,
                        color: KColors.bone,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentArtist,
                      style: KTypography.boardMono.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    // Requester chip
                    Row(
                      children: [
                        KAvatar(initial: singerInitial, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          singerName,
                          style: KTypography.boardMono.copyWith(fontSize: 14),
                        ),
                        const SizedBox(width: 12),
                        const SizedBox(
                          height: 30,
                          child: KEqualiser(height: 30, barCount: 4),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Progress
                    Row(
                      children: [
                        Text(elapsed, style: KTypography.boardMono.copyWith(fontSize: 13)),
                        const SizedBox(width: 12),
                        Expanded(child: KProgressBar(progress: progress, height: 8)),
                        const SizedBox(width: 12),
                        Text(duration, style: KTypography.boardMono.copyWith(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Control lives on the host\'s phone',
                      style: KTypography.boardMono.copyWith(fontSize: 12, color: KColors.bone28),
                    ),
                  ],
                ),
              ),
            ),

            // Hairline
            Container(width: 1, color: KColors.hairline),

            // Right: Up next
            Expanded(
              flex: 85,
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.boardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UP NEXT · ${upNext.length}',
                      style: KTypography.boardMono.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: upNext.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final e = upNext[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: KColors.ink650,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: KColors.hairline, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${i + 1}',
                                  style: KTypography.boardMono.copyWith(fontSize: 26, color: KColors.bone28),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: KColors.ink700,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.music_note, color: KColors.bone28, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: const TextStyle(
                                          fontFamily: 'BricolageGrotesque',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 21,
                                          color: KColors.bone,
                                        ),
                                      ),
                                      Text(
                                        e.artist,
                                        style: KTypography.boardMono.copyWith(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                // Requester
                                Row(
                                  children: [
                                    KAvatar(initial: e.requesterInitial, size: 20),
                                    const SizedBox(width: 6),
                                    Text(e.requester, style: KTypography.boardMono.copyWith(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add songs from your phone - they appear here instantly',
                      style: KTypography.boardMono.copyWith(fontSize: 12, color: KColors.bone28),
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

class _QueueEntry {
  final String title;
  final String artist;
  final String requester;
  final String requesterInitial;

  const _QueueEntry({
    required this.title,
    required this.artist,
    required this.requester,
    required this.requesterInitial,
  });
}
