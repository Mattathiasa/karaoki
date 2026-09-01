import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// The signature lyric component
/// Three stacked lines with the current line having a wipe-fill effect
class KLyricWidget extends StatelessWidget {
  final String? previousLine;
  final String currentLine;
  final String? nextLine;
  final double lineProgress; // 0.0 to 1.0, the wipe position

  const KLyricWidget({
    super.key,
    this.previousLine,
    required this.currentLine,
    this.nextLine,
    this.lineProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous line (bone/20, 30px on board / 15px on mobile)
        if (previousLine != null)
          Text(
            previousLine!,
            style: KTypography.boardLyricNext.copyWith(
              color: KColors.bone.withOpacity(0.2),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        if (previousLine != null) const SizedBox(height: 12),
        // Current line with wipe fill
        _WipedLyricLine(
          text: currentLine,
          progress: lineProgress,
        ),
        if (nextLine != null) const SizedBox(height: 12),
        // Next line (bone/42, 33px on board / 18px on mobile)
        if (nextLine != null)
          Text(
            nextLine!,
            style: KTypography.boardLyricNext.copyWith(
              color: KColors.bone45,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

/// Board-scale lyric widget
class KBoardLyricWidget extends StatelessWidget {
  final String? previousLine;
  final String currentLine;
  final String? nextLine;
  final double lineProgress;

  const KBoardLyricWidget({
    super.key,
    this.previousLine,
    required this.currentLine,
    this.nextLine,
    this.lineProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (previousLine != null)
          Text(
            previousLine!,
            style: KTypography.boardLyricNext.copyWith(
              color: KColors.bone.withOpacity(0.2),
            ),
            textAlign: TextAlign.center,
          ),
        if (previousLine != null) const SizedBox(height: 20),
        _WipedLyricLine(
          text: currentLine,
          progress: lineProgress,
          fontSize: KTypography.currentLyricBoard,
        ),
        if (nextLine != null) const SizedBox(height: 20),
        if (nextLine != null)
          Text(
            nextLine!,
            style: KTypography.boardLyricNext,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

/// Internal: lyric line with gradient wipe fill
class _WipedLyricLine extends StatelessWidget {
  final String text;
  final double progress;
  final double fontSize;

  const _WipedLyricLine({
    required this.text,
    required this.progress,
    this.fontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Base layer (bone/24)
            Text(
              text,
              style: KTypography.displaySection.copyWith(
                fontSize: fontSize,
                color: KColors.bone.withOpacity(0.24),
              ),
              textAlign: TextAlign.center,
            ),
            // Gradient fill layer (clipped by progress)
            ClipRect(
              clipper: _ProgressClipper(progress: progress),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFFFDFDF5), // #FFFDF5
                      KColors.lime,
                      KColors.teal,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  text,
                  style: KTypography.displaySection.copyWith(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Clipper that clips from right to left based on progress
class _ProgressClipper extends CustomClipper<Rect> {
  final double progress;

  _ProgressClipper({required this.progress});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_ProgressClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

/// Duet lyric widget (part A / part B / BOTH)
class KDuetLyricWidget extends StatelessWidget {
  final String text;
  final String part; // A, B, BOTH
  final double lineProgress;

  const KDuetLyricWidget({
    super.key,
    required this.text,
    required this.part,
    this.lineProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isPartA = part == 'A';
    final isPartB = part == 'B';
    final isBoth = part == 'BOTH';

    final fillColor = isBoth
        ? null // use dual gradient
        : isPartA
            ? KColors.lime
            : KColors.teal;

    final borderColor = isPartA ? KColors.lime : KColors.teal;
    final dimmed = isPartB ? 0.6 : 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isBoth ? null : (isPartA ? KColors.limeTint : KColors.teal).withOpacity(0.15),
        border: Border(
          left: BorderSide(
            color: isBoth ? KColors.hairline : borderColor,
            width: 3,
          ),
        ),
      ),
      child: Opacity(
        opacity: dimmed,
        child: _WipedLyricLine(
          text: text,
          progress: lineProgress,
          fontSize: isBoth ? 22 : 19,
        ),
      ),
    );
  }
}
