import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';

class TurnNextScreen extends StatelessWidget {
  final String songTitle;
  final String artist;
  final String duration;
  final String difficulty;
  final int countdownSeconds;
  final VoidCallback? onReady;
  final VoidCallback? onSkip;

  const TurnNextScreen({
    super.key,
    this.songTitle = 'Neon Midnight',
    this.artist = 'Vela Cruz',
    this.duration = '3:42',
    this.difficulty = 'Medium',
    this.countdownSeconds = 6,
    this.onReady,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.5,
            colors: [KColors.limeTint, KColors.ink800],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                'GET READY',
                style: KTypography.monoLabel.copyWith(fontSize: 11, letterSpacing: 0.28),
              ),
              const SizedBox(height: 16),
              const Text(
                "YOU'RE UP NEXT!",
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
                  fontSize: 42, color: KColors.bone, letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Countdown ring
              Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: KColors.lime, width: 3),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$countdownSeconds',
                      style: const TextStyle(
                        fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
                        fontSize: 62, color: KColors.lime,
                      ),
                    ),
                    Text('SECONDS', style: KTypography.monoLabel.copyWith(fontSize: 8)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Song card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
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
                      child: const Icon(Icons.music_note, color: KColors.bone28, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOUR SONG', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                          Text(songTitle, style: KTypography.uiRowTitle),
                          Text('$artist \u00b7 $duration \u00b7 $difficulty', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              KPrimaryButton(label: "I'm ready", onPressed: onReady),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onSkip,
                child: Text('Skip my turn', style: KTypography.uiButton.copyWith(
                  color: KColors.bone55, fontWeight: FontWeight.w400, fontSize: 13,
                )),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
