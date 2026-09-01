import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/cards.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  const ProfileScreen({super.key, this.onBack, this.onSettings});

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
                  const Spacer(),
                  KIconButton(icon: Icons.settings, size: 34, onPressed: onSettings),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
                children: [
                  const SizedBox(height: 16),
                  // Avatar + name
                  Center(
                    child: Column(
                      children: [
                        const KAvatar(initial: 'M', size: 74),
                        const SizedBox(height: 12),
                        const Text('Matt', style: TextStyle(
                          fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                          fontSize: 23, color: KColors.bone,
                        )),
                        const SizedBox(height: 4),
                        Text('@matt_sings', style: KTypography.monoLabel.copyWith(fontSize: 10)),
                        const SizedBox(height: 8),
                        const KLevelChip(label: 'KARAOKE LEGEND', level: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _StatTile(label: 'SONGS', value: '142'),
                      _StatTile(label: 'AVG', value: '84'),
                      _StatTile(label: 'BEST', value: '96', highlighted: true),
                      _StatTile(label: 'WINS', value: '7'),
                      _StatTile(label: 'FAV GENRE', value: 'Pop'),
                      _StatTile(label: 'STREAK', value: '12'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tabs
                  _TabBar(),
                  const SizedBox(height: 16),
                  // Performance list
                  ...List.generate(5, (i) {
                    final songs = ['Neon Midnight', 'Concrete Halo', 'Slow Gold', 'Loose Change', 'Old Sepia Letters'];
                    final artists = ['Vela Cruz', 'The Static Kings', 'Amara Reign', 'Kobi Blaze', 'Frank Delacroix'];
                    final scores = ['96', '87', '78', '72', '68'];
                    final ranks = ['SUPERSTAR', 'GREAT', 'GREAT', 'SOLID', 'SOLID'];
                    final colors = [KColors.gold, KColors.mint, KColors.mint, KColors.teal, KColors.teal];
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
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: KColors.ink700),
                              alignment: Alignment.center,
                              child: const Icon(Icons.music_note, color: KColors.bone28, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(songs[i], style: KTypography.uiRowTitle),
                                  Text(artists[i], style: KTypography.monoLabel.copyWith(fontSize: 10)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(scores[i], style: TextStyle(
                                  fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                                  fontSize: 19, color: colors[i],
                                )),
                                Text(ranks[i], style: KTypography.monoLabel.copyWith(fontSize: 9, color: colors[i])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;
  const _StatTile({required this.label, required this.value, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? KColors.limeTint.withOpacity(0.2) : KColors.ink650,
        borderRadius: BorderRadius.circular(KRadius.tile),
        border: Border.all(color: KColors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: KTypography.monoLabel.copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
            fontSize: 18, color: highlighted ? KColors.lime : KColors.bone,
          )),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KColors.ink700,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Tab(label: 'Performances', selected: true),
          _Tab(label: 'Badges', selected: false),
          _Tab(label: 'Stats', selected: false),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  const _Tab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? KColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(label, style: KTypography.uiButton.copyWith(
          fontSize: 13, color: selected ? KColors.onAccent : KColors.bone55,
        )),
      ),
    );
  }
}
