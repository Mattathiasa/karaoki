import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Dev-only screen picker overlay for quick navigation during testing.
/// Accessible via floating button in bottom-right corner.
class ScreenPickerOverlay extends StatelessWidget {
  const ScreenPickerOverlay({super.key});

  static const _screens = <String, List<_ScreenGroup>>{
    'Onboarding': [
      _ScreenGroup('Onboarding Flow', [
        ('Splash', '/'),
        ('Onboarding', '/onboarding'),
        ('Welcome', '/welcome'),
        ('Sign In', '/signin'),
        ('Sign Up', '/signup'),
        ('Setup', '/setup'),
      ]),
    ],
    'Core': [
      _ScreenGroup('Home & Rooms', [
        ('Home', '/home'),
        ('Create Room', '/create-room'),
        ('Join Room', '/join-room'),
        ('QR Scan', '/qr'),
        ('Lobby', '/lobby'),
      ]),
      _ScreenGroup('Library', [
        ('Library', '/library'),
        ('Search', '/search'),
        ('Song Details', '/details'),
        ('Queue', '/queue'),
      ]),
    ],
    'Performance': [
      _ScreenGroup('Singing Flow', [
        ('Turn Next', '/turn-next'),
        ('Turn Now', '/turn-now'),
        ('Singing (Live)', '/singing'),
        ('Complete', '/complete'),
      ]),
    ],
    'Profile': [
      _ScreenGroup('Profile & Stats', [
        ('Leaderboard', '/leaderboard'),
        ('History', '/history'),
        ('Achievements', '/achievements'),
        ('Profile', '/profile'),
        ('Settings', '/settings'),
      ]),
    ],
    'Board (TV)': [
      _ScreenGroup('TV Board Screens', [
        ('Board Wait', '/tv'),
        ('Board Countdown', '/tv/countdown'),
        ('Board Queue', '/tv/queue'),
        ('Board Performance', '/tv/performance'),
        ('Board VS', '/tv/vs'),
        ('Board Reveal', '/tv/reveal'),
        ('Board Leaderboard', '/tv/leaderboard'),
      ]),
    ],
    'Game Modes': [
      _ScreenGroup('Game Modes', [
        ('Battle', '/battle'),
        ('Team', '/team'),
        ('Duet', '/duet'),
        ('Pass the Mic', '/pass-mic'),
      ]),
    ],
    'Edge States': [
      _ScreenGroup('Error & Empty States', [
        ('Empty Queue', '/edge/empty-queue'),
        ('No Results', '/edge/no-results'),
        ('Mic Permission', '/edge/mic-permission'),
        ('Mic Lost', '/edge/mic-lost'),
        ('Weak Connection', '/edge/weak-connection'),
        ('Player Dropped', '/edge/player-dropped'),
        ('Room Full', '/edge/room-full'),
        ('Bad Code', '/edge/bad-code'),
        ('Unavailable', '/edge/unavailable'),
        ('No History', '/edge/no-history'),
        ('No Badges', '/edge/no-badges'),
        ('Waiting', '/edge/waiting'),
      ]),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: KColors.ink800,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: KColors.hairline, width: 0.5)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KColors.bone28,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'NAVIGATE TO SCREEN (${_screens.values.expand((g) => g).expand((g) => g.screens).length})',
                style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    for (final entry in _screens.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 6),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: KTypography.monoLabel.copyWith(
                            fontSize: 10,
                            color: KColors.lime,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final group in entry.value) ...[
                        for (final (label, path) in group.screens)
                          _ScreenTile(label: label, path: path),
                      ],
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScreenGroup {
  final String name;
  final List<(String, String)> screens;
  const _ScreenGroup(this.name, this.screens);
}

class _ScreenTile extends StatelessWidget {
  final String label;
  final String path;
  const _ScreenTile({required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).uri.toString();
    final isActive = current == path;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // close the sheet
        context.go(path);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? KColors.limeTint.withOpacity(0.15) : KColors.ink700,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? KColors.lime.withOpacity(0.4) : KColors.hairline,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'InstrumentSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                  color: isActive ? KColors.lime : KColors.bone,
                ),
              ),
            ),
            Text(
              path,
              style: KTypography.monoCode.copyWith(fontSize: 10, color: KColors.bone28),
            ),
          ],
        ),
      ),
    );
  }
}
