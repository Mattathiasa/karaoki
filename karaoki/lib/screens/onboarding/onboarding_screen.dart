import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      title: 'Sing. Compete.\nHave Fun.',
      body: 'Karaoki turns any room into a karaoke stage. Queue songs, take turns singing, and compete for the highest score.',
      illustration: 'mic',
    ),
    _OnboardingPage(
      title: 'Your Phone Becomes\nYour Microphone.',
      body: 'No extra hardware needed. Your phone captures your voice and sends it to the board in real time. Just tap and sing.',
      illustration: 'connect',
    ),
    _OnboardingPage(
      title: 'Become the\nKaraoke Champion.',
      body: 'Get scored on pitch, timing, and energy. Climb the leaderboard, unlock achievements, and earn your spot as a Karaoki Legend.',
      illustration: 'trophy',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 16,
              right: 20,
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Text(
                  'Skip',
                  style: KTypography.uiButton.copyWith(
                    color: KColors.bone55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            // Page view
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => _pages[i],
            ),
            // Bottom: progress dots + continue
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress dots
                  Row(
                    children: List.generate(3, (i) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _currentPage ? 26 : 8,
                      height: 5,
                      decoration: BoxDecoration(
                        color: i == _currentPage ? KColors.lime : KColors.bone28,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    )),
                  ),
                  // Continue button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < 2) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      } else {
                        widget.onComplete();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: KColors.lime,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'InstrumentSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: KColors.onAccent,
                        ),
                      ),
                    ),
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

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String body;
  final String illustration;

  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 80),
          // Illustration placeholder
          Container(
            width: 288,
            height: 288,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: KColors.ink700,
              border: Border.all(color: KColors.hairline, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Icon(
              illustration == 'mic' ? Icons.mic : illustration == 'connect' ? Icons.wifi : Icons.emoji_events,
              size: 80,
              color: KColors.bone28,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            title,
            style: KTypography.displayHero.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Body
          Text(
            body,
            style: KTypography.uiBody.copyWith(fontSize: 14.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
