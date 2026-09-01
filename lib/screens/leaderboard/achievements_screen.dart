import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';

class AchievementsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const AchievementsScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, KSpacing.mobilePaddingV, KSpacing.mobilePaddingH, 0),
            child: Row(children: [
              KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: onBack),
              const SizedBox(width: 12),
              const Expanded(child: Text('Achievements', style: TextStyle(
                fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700, fontSize: 22, color: KColors.bone,
              ))),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(KSpacing.mobilePaddingH), children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: KColors.limeTint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  border: Border.all(color: KColors.limeTint.withOpacity(0.3), width: 0.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('JUST UNLOCKED', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.lime)),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.emoji_events, color: KColors.gold, size: 30),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Pitch Perfect', style: KTypography.uiRowTitle.copyWith(fontSize: 15)),
                      Text('92% on Neon Midnight \u2014 nice.', style: KTypography.monoLabel.copyWith(fontSize: 10)),
                    ])),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Text('ALL BADGES', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                const Spacer(),
                Text('3 / 6 UNLOCKED', style: KTypography.monoLabel.copyWith(fontSize: 9)),
              ]),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.4,
                children: const [
                  _Badge(icon: Icons.mic, name: 'First Song', desc: 'Complete your first performance', unlocked: true, proof: 'Neon Midnight'),
                  _Badge(icon: Icons.music_note, name: 'Pitch Perfect', desc: 'Score 90%+ on pitch', unlocked: true, proof: '92%'),
                  _Badge(icon: Icons.whatshot, name: 'Unstoppable', desc: '10 song streak', unlocked: true, proof: '12 songs'),
                  _Badge(icon: Icons.emoji_events, name: 'Karaoke Champion', desc: 'Win 50 battles', unlocked: false, progress: '12 / 50'),
                  _Badge(icon: Icons.celebration, name: 'Party Starter', desc: 'Host 10 rooms', unlocked: false, progress: '3 / 10'),
                  _Badge(icon: Icons.workspace_premium, name: 'Room Royalty', desc: 'Score 100 in any song', unlocked: false, progress: 'Best: 96'),
                ],
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String name;
  final String desc;
  final bool unlocked;
  final String? proof;
  final String? progress;
  const _Badge({required this.icon, required this.name, required this.desc, required this.unlocked, this.proof, this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? KColors.limeTint.withOpacity(0.3) : KColors.ink700,
        borderRadius: BorderRadius.circular(KRadius.tile),
        border: Border.all(color: unlocked ? KColors.limeTint : KColors.hairline, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: unlocked ? KColors.gold : KColors.bone28, size: 26),
        const SizedBox(height: 8),
        Text(name, style: KTypography.uiRowTitle.copyWith(fontSize: 13)),
        const SizedBox(height: 2),
        Text(desc, style: KTypography.monoLabel.copyWith(fontSize: 10.5), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        if (unlocked)
          Text('\u2713 UNLOCKED', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.mint))
        else if (progress != null)
          Text(progress!, style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.bone28)),
      ]),
    );
  }
}
