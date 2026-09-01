import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/ui_components.dart';
import '../../models/song.dart';

class QueueScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddMore;

  const QueueScreen({super.key, this.onBack, this.onAddMore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH, KSpacing.mobilePaddingV, KSpacing.mobilePaddingH, 0,
              ),
              child: Row(
                children: [
                  KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: onBack),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Queue', style: TextStyle(
                      fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                      fontSize: 22, color: KColors.bone,
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(KSpacing.mobilePaddingH),
                children: [
                  // Now playing card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KColors.limeTint.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(KRadius.tile),
                      border: Border.all(color: KColors.limeTint.withOpacity(0.3), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54, height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(KRadius.tile),
                            color: KColors.ink700,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.music_note, color: KColors.bone28, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NOW PLAYING \u00b7 MATT', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.lime)),
                              const SizedBox(height: 4),
                              Text('Neon Midnight', style: KTypography.uiRowTitle),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('1:32 / 3:42', style: KTypography.monoLabel.copyWith(fontSize: 10)),
                                  const SizedBox(width: 8),
                                  const SizedBox(height: 30, child: KEqualiser(height: 30, barCount: 4)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Up next
                  Row(
                    children: [
                      Text('UP NEXT \u00b7 3', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Text('Reorder', style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.lime)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Queue rows
                  ...List.generate(3, (i) {
                    final songs = fixtureSongs.sublist(1, 4);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: KColors.ink650,
                          borderRadius: BorderRadius.circular(KRadius.tile),
                          border: Border.all(color: KColors.hairline, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Text('${i + 1}', style: KTypography.monoLabel.copyWith(fontSize: 14, color: KColors.bone28)),
                            const SizedBox(width: 12),
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: KColors.ink700,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.music_note, color: KColors.bone28, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(songs[i].title, style: KTypography.uiRowTitle.copyWith(fontSize: 13)),
                                  Row(
                                    children: [
                                      const KAvatar(initial: 'S', size: 16),
                                      const SizedBox(width: 6),
                                      Text('Sara', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.close, color: KColors.bone28, size: 16),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Info strip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: KColors.hairline, width: 0.5, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(KRadius.tile),
                    ),
                    child: Text(
                      'You sing 3rd \u2014 about 8 minutes away',
                      style: KTypography.monoLabel.copyWith(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: KSecondaryButton(label: 'Add another', onPressed: onAddMore)),
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
