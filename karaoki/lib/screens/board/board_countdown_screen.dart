import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class BoardCountdownScreen extends StatefulWidget {
  final String singerName;
  final String songTitle;
  final VoidCallback? onComplete;

  const BoardCountdownScreen({
    super.key,
    required this.singerName,
    required this.songTitle,
    this.onComplete,
  });

  @override
  State<BoardCountdownScreen> createState() => _BoardCountdownScreenState();
}

class _BoardCountdownScreenState extends State<BoardCountdownScreen>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _ringController;
  int _count = 3;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _countController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _startCountdown();
  }

  void _startCountdown() async {
    _countController.forward();
    for (int i = 3; i >= 1; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _count = i);
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _count = 0);
  }

  @override
  void dispose() {
    _countController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink900,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.5,
            colors: [KColors.limeTint, KColors.ink900],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Singer + song
            Text(
              '${widget.singerName.toUpperCase()} · ${widget.songTitle.toUpperCase()}',
              style: KTypography.boardMono.copyWith(
                fontSize: 16,
                letterSpacing: 0.32,
              ),
            ),
            const SizedBox(height: 60),

            // Countdown ring + number
            AnimatedBuilder(
              animation: _ringController,
              builder: (context, child) {
                final ringScale = 0.7 + _ringController.value * 0.9;
                final ringOpacity = 0.7 - _ringController.value * 0.7;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ring
                    Transform.scale(
                      scale: ringScale,
                      child: Container(
                        width: 420,
                        height: 420,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: KColors.lime.withOpacity(ringOpacity),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    // Number
                    Text(
                      _count == 0 ? 'SING!' : '$_count',
                      style: TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w800,
                        fontSize: _count == 0 ? 120 : 200,
                        color: KColors.lime,
                        letterSpacing: -9,
                        shadows: [
                          BoxShadow(
                            color: KColors.lime.withOpacity(0.5),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 60),
            Text(
              'Get ready to sing!',
              style: KTypography.boardMono.copyWith(
                fontSize: 14,
                color: KColors.bone45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
