import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/radius.dart';
import '../../widgets/ui_components.dart';

class TurnNowScreen extends StatelessWidget {
  final String songTitle;
  final String artist;
  final VoidCallback? onStart;

  const TurnNowScreen({
    super.key,
    this.songTitle = 'Neon Midnight',
    this.artist = 'Vela Cruz',
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [KColors.limeTint, KColors.ink800],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // "YOUR TURN!" title
              const Text(
                'YOUR TURN!',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
                  fontSize: 46, color: KColors.bone, letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 40),
              // Mic tile
              Container(
                width: 190, height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  gradient: const LinearGradient(
                    colors: [KColors.lime, KColors.tangerine],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic, color: KColors.onAccent, size: 82),
              ),
              const SizedBox(height: 24),
              // Song info
              Text(songTitle, style: const TextStyle(
                fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                fontSize: 22, color: KColors.bone,
              )),
              const SizedBox(height: 4),
              Text(artist, style: KTypography.monoLabel.copyWith(fontSize: 12)),
              const SizedBox(height: 16),
              // Mic status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: KColors.mint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: KColors.mint.withOpacity(0.3), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const KLiveDot(color: KColors.mint, size: 6),
                    const SizedBox(width: 8),
                    Text('Microphone live \u00b7 phone connected',
                      style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.mint)),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Start button
              GestureDetector(
                onTap: onStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 19),
                  decoration: BoxDecoration(
                    color: KColors.bone,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'START SINGING',
                    style: KTypography.uiButton.copyWith(color: KColors.onAccent),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
