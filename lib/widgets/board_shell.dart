import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Board shell: ink base with two radial washes + scanline veil
/// Apply as a wrapper around all board screens
class BoardShell extends StatelessWidget {
  final Widget child;

  const BoardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ink base
        Container(color: KColors.ink900),
        // Lime radial wash (top-centre)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.6),
                radius: 1.2,
                colors: [
                  Color(0x18C4F53E), // lime 10%
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Teal radial wash (bottom-left)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, 0.8),
                radius: 1.0,
                colors: [
                  Color(0x105FDCE4), // teal 6%
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Scanline veil (2px lines at 0.5 opacity)
        Positioned.fill(
          child: CustomPaint(
            painter: _ScanlinePainter(),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
