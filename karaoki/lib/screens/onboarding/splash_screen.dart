import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/ui_components.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    Timer(const Duration(milliseconds: 1200), widget.onComplete);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              KColors.limeTint,
              Color(0xFF1A1509),
              KColors.ink800,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Mic tile with floatY + ringOut halo
            AnimatedBuilder(
              animation: Listenable.merge([_floatController, _ringController]),
              builder: (context, child) {
                final floatY = _floatController.value * 20 - 10;
                final ringScale = 0.7 + _ringController.value * 0.9;
                final ringOpacity = 0.7 - _ringController.value * 0.7;
                return Transform.translate(
                  offset: Offset(0, floatY),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ring halo
                      Transform.scale(
                        scale: ringScale,
                        child: Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: KColors.lime.withOpacity(ringOpacity),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Mic tile
                      Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [KColors.lime, KColors.tangerine],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '🎤',
                          style: TextStyle(fontSize: 52),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Wordmark
            const Text(
              'KARAOKI',
              style: TextStyle(
                fontFamily: 'BricolageGrotesque',
                fontWeight: FontWeight.w800,
                fontSize: 46,
                color: KColors.bone,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'SING · COMPETE · REPEAT',
              style: KTypography.monoLabel.copyWith(
                fontSize: 11,
                letterSpacing: 0.3,
                color: KColors.bone45,
              ),
            ),
            const SizedBox(height: 32),
            // Equaliser
            const KEqualiser(height: 44),
            const Spacer(flex: 3),
            // Tap to continue
            Padding(
              padding: const EdgeInsets.only(bottom: 52),
              child: Text(
                'TAP TO CONTINUE',
                style: KTypography.monoLabel.copyWith(
                  fontSize: 10,
                  color: KColors.bone28,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
