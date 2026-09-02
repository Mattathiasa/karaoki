import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onContinue;

  const WelcomeScreen({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Mic tile
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  gradient: const LinearGradient(
                    colors: [KColors.lime, KColors.tangerine],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic, color: KColors.onAccent, size: 28),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Welcome to the party.',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create an account to save your scores,\nunlock achievements, and compete globally.',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              // Buttons
              KPrimaryButton(
                label: 'Create account',
                onPressed: onContinue,
              ),
              const SizedBox(height: 12),
              const KSecondaryButton(
                label: 'Sign in with email',
              ),
              const SizedBox(height: 12),
              const KSecondaryButton(
                label: 'Continue with Google',
                icon: Icon(Icons.g_mobiledata, color: KColors.bone, size: 20),
              ),
              const SizedBox(height: 20),
              // Guest
              GestureDetector(
                onTap: onContinue,
                child: Text(
                  'Continue as guest →',
                  style: KTypography.uiButton.copyWith(
                    color: KColors.bone55,
                    fontWeight: FontWeight.w400,
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
