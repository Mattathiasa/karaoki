import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0; // 0=Room, 1=Friends, 2=Global

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
                KSpacing.mobilePaddingH,
                KSpacing.mobilePaddingV,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Row(
                children: [
                  const KIconButton(icon: Icons.arrow_back_ios_new, size: 34),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: KColors.bone,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Segmented control
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.mobilePaddingH,
                16,
                KSpacing.mobilePaddingH,
                0,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: KColors.ink700,
                  borderRadius: BorderRadius.circular(KRadius.pill),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Room',
                      selected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                    _TabButton(
                      label: 'Friends',
                      selected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                    _TabButton(
                      label: 'Global',
                      selected: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2),
                    ),
                  ],
                ),
              ),
            ),

            // Podium
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd place
                  _PodiumColumn(
                    rank: 2,
                    initial: 'S',
                    score: 84,
                    height: 74,
                    avatarSize: 52,
                  ),
                  const SizedBox(width: 16),
                  // 1st place
                  _PodiumColumn(
                    rank: 1,
                    initial: 'M',
                    score: 96,
                    height: 104,
                    avatarSize: 64,
                    showCrown: true,
                  ),
                  const SizedBox(width: 16),
                  // 3rd place
                  _PodiumColumn(
                    rank: 3,
                    initial: 'D',
                    score: 72,
                    height: 56,
                    avatarSize: 48,
                  ),
                ],
              ),
            ),

            // Rankings list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.mobilePaddingH,
                  0,
                  KSpacing.mobilePaddingH,
                  40,
                ),
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final names = ['Matt', 'Sara', 'Dawit', 'Leah', 'Tom', 'Nia', 'Kai', 'Zoe'];
                  final scores = [96, 84, 72, 68, 65, 61, 58, 52];
                  return KLeaderboardRow(
                    rank: i + 1,
                    name: names[i],
                    score: scores[i],
                    isCurrentUser: i == 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _TabButton({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? KColors.lime : Colors.transparent,
            borderRadius: BorderRadius.circular(KRadius.pill),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: KTypography.uiButton.copyWith(
              fontSize: 13,
              color: selected ? KColors.onAccent : KColors.bone55,
            ),
          ),
        ),
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final int rank;
  final String initial;
  final int score;
  final double height;
  final double avatarSize;
  final bool showCrown;

  const _PodiumColumn({
    required this.rank,
    required this.initial,
    required this.score,
    required this.height,
    required this.avatarSize,
    this.showCrown = false,
  });

  Color get _color {
    switch (rank) {
      case 1: return KColors.gold;
      case 2: return KColors.bone;
      case 3: return KColors.bone;
      default: return KColors.bone45;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showCrown) ...[
          const Text('👑', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 8),
        ],
        // Avatar
        KAvatar(initial: initial, size: avatarSize),
        const SizedBox(height: 8),
        // Rank
        Text(
          rank == 1 ? '1ST' : rank == 2 ? '2ND' : '3RD',
          style: KTypography.monoLabel.copyWith(
            fontSize: 11,
            color: _color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        // Score
        Text(
          score.toString(),
          style: KTypography.monoLabel.copyWith(
            fontSize: 13,
            color: _color,
          ),
        ),
        const SizedBox(height: 8),
        // Column
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: rank == 1
                ? KColors.gold.withOpacity(0.3)
                : KColors.ink600,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            border: Border.all(
              color: rank == 1
                  ? KColors.gold.withOpacity(0.5)
                  : KColors.hairline,
              width: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
