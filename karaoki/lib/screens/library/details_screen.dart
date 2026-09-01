import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../models/song.dart';

class DetailsScreen extends StatelessWidget {
  final Song? song;
  final VoidCallback? onBack;
  final VoidCallback? onAddToQueue;

  const DetailsScreen({super.key, this.song, this.onBack, this.onAddToQueue});

  @override
  Widget build(BuildContext context) {
    final s = song ?? fixtureSongs.first;
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover art
            Stack(
              children: [
                Container(
                  height: 346,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [KColors.limeTint, KColors.ink700],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.music_note, color: KColors.bone28, size: 64),
                ),
                // Gradient scrim
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, KColors.ink800],
                      ),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: 56, left: 20,
                  child: KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: onBack),
                ),
                // Title over art
                Positioned(
                  bottom: 20, left: 20, right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title, style: const TextStyle(
                        fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                        fontSize: 28, color: KColors.bone,
                      )),
                      const SizedBox(height: 4),
                      Text(s.artist, style: KTypography.monoLabel.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            // Meta tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _Tag(label: s.difficulty),
                  _Tag(label: s.durationLabel),
                  _Tag(label: s.genre),
                  _Tag(label: 'TRENDING', color: KColors.red),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stat cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
              child: Row(
                children: [
                  _StatCard(label: 'ROOM BEST', value: '94', color: KColors.bone),
                  const SizedBox(width: 10),
                  _StatCard(label: 'YOUR BEST', value: '87', color: KColors.lime),
                  const SizedBox(width: 10),
                  _StatCard(label: 'PLAYS', value: '12', color: KColors.bone),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
              child: KPrimaryButton(label: 'Add to queue', onPressed: onAddToQueue),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
              child: Row(
                children: [
                  Expanded(child: KSecondaryButton(
                    label: 'Preview',
                    icon: const Icon(Icons.play_arrow, color: KColors.bone, size: 16),
                    onPressed: () {},
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: KSecondaryButton(
                    label: 'Favourite',
                    icon: const Icon(Icons.favorite_border, color: KColors.bone, size: 16),
                    onPressed: () {},
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  const _Tag({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: KColors.ink700,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label.toUpperCase(), style: KTypography.monoLabel.copyWith(
        fontSize: 9, color: color ?? KColors.bone45,
      )),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color == KColors.lime ? KColors.limeTint.withOpacity(0.2) : KColors.ink650,
          borderRadius: BorderRadius.circular(KRadius.tile),
          border: Border.all(color: KColors.hairline, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: KTypography.monoLabel.copyWith(fontSize: 9)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(
              fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
              fontSize: 22, color: color,
            )),
          ],
        ),
      ),
    );
  }
}
