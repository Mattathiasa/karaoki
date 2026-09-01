import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Status tag: READY, SINGING, PICKING SONG, DISCONNECTED
class KStatusTag extends StatelessWidget {
  final String status;

  const KStatusTag({super.key, required this.status});

  Color get _color {
    switch (status.toUpperCase()) {
      case 'READY':
        return KColors.mint;
      case 'SINGING':
        return KColors.teal;
      case 'PICKING SONG':
        return KColors.bone45;
      case 'DISCONNECTED':
        return KColors.red;
      default:
        return KColors.bone45;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '[ ${status.toUpperCase()} ]',
        style: KTypography.monoLabel.copyWith(
          fontSize: 9,
          color: _color,
          letterSpacing: 0.12,
        ),
      ),
    );
  }
}

/// Live dot with pulse animation
class KLiveDot extends StatefulWidget {
  final Color color;
  final double size;

  const KLiveDot({
    super.key,
    this.color = KColors.mint,
    this.size = 8,
  });

  @override
  State<KLiveDot> createState() => _KLiveDotState();
}

class _KLiveDotState extends State<KLiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.55 + _controller.value * 0.45;
        final scale = 1.0 + _controller.value * 0.06;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(opacity),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(opacity * 0.65),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Progress bar (5-8px track, lime→teal fill)
class KProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;

  const KProgressBar({
    super.key,
    required this.progress,
    this.height = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: KColors.bone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: KColors.scoreFillGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: KColors.lime.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Equaliser (18 bars driven by clock)
class KEqualiser extends StatefulWidget {
  final int barCount;
  final double height;
  final bool animate;

  const KEqualiser({
    super.key,
    this.barCount = 18,
    this.height = 44,
    this.animate = true,
  });

  @override
  State<KEqualiser> createState() => _KEqualiserState();
}

class _KEqualiserState extends State<KEqualiser>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animate) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animate ? _controller : const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (i) {
            final phase = (i / widget.barCount) * 3.14159 * 2;
            final t = widget.animate ? _controller.value : 0.5;
            final h = (0.3 + 0.7 * (0.5 + 0.5 * sin(phase + t * 6.28).abs()));
            return Container(
              width: 3,
              height: widget.height * h,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                gradient: KColors.scoreFillGradient,
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Level chip (gold pill, mono)
class KLevelChip extends StatelessWidget {
  final String label;
  final int level;

  const KLevelChip({super.key, required this.label, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KColors.gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KColors.gold.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        '$label · LV $level',
        style: KTypography.monoLabel.copyWith(
          fontSize: 10,
          color: KColors.gold,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Micro status pill with live dot and level meter
class KMicStatus extends StatelessWidget {
  final bool connected;
  final double level; // 0.0 to 1.0

  const KMicStatus({
    super.key,
    this.connected = true,
    this.level = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: connected ? KColors.mint.withOpacity(0.1) : KColors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: connected ? KColors.mint.withOpacity(0.3) : KColors.red.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KLiveDot(
            color: connected ? KColors.mint : KColors.red,
            size: 6,
          ),
          const SizedBox(width: 8),
          // Level meter
          Container(
            width: 30,
            height: 8,
            decoration: BoxDecoration(
              color: KColors.ink700,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: level.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: connected ? KColors.mint : KColors.red,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            connected ? 'GOOD' : 'LOST',
            style: KTypography.monoLabel.copyWith(
              fontSize: 9,
              color: connected ? KColors.mint : KColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category pill (horizontally scrollable)
class KCategoryPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const KCategoryPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? KColors.limeTint : KColors.ink600,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? KColors.lime : KColors.hairline,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: KTypography.uiButton.copyWith(
            fontSize: 12.5,
            color: selected ? KColors.lime : KColors.bone55,
          ),
        ),
      ),
    );
  }
}
