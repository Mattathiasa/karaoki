import 'package:flutter/material.dart';

/// Karaoki design system color tokens
/// Canonical values from oklch() — hex approximations for Flutter
class KColors {
  KColors._();

  // Ink scale (backgrounds)
  static const ink900 = Color(0xFF0B0A07);
  static const ink850 = Color(0xFF0C0B08);
  static const ink800 = Color(0xFF100E0A);
  static const ink700 = Color(0xFF16130E);
  static const ink650 = Color(0xFF17140E);
  static const ink600 = Color(0xFF1C1912);
  static const ink550 = Color(0xFF211D15);

  // Text colors
  static const bone = Color(0xFFF5F1E8);
  static const bone55 = Color(0x8CF5F1E8); // 55% opacity
  static const bone45 = Color(0x73F5F1E8); // 45% opacity
  static const bone28 = Color(0x47F5F1E8); // 28% opacity
  static const onAccent = Color(0xFF0F0E0A);

  // Accent colors
  static const lime = Color(0xFFC4F53E); // Primary action, brand
  static const limeDeep = Color(0xFF7FA52B); // Pressed primary
  static const limeTint = Color(0xFF4E6A18); // Tinted panel washes
  static const tangerine = Color(0xFFFFA149); // Secondary accent
  static const teal = Color(0xFF5FDCE4); // Tertiary accent
  static const mint = Color(0xFF4CE9AE); // Success, ready
  static const gold = Color(0xFFF7C13B); // Scores, ranks
  static const red = Color(0xFFF76242); // Danger

  // Hairline borders
  static const hairline = Color(0x17F5F1E8); // ~9% opacity
  static const hairlineHigh = Color(0x29F5F1E8); // ~16% opacity

  // Semi-transparent
  static const panelFill = Color(0x12F5F1E8); // ~7% opacity for secondary buttons
  static const limeShadow = Color(0x80C4F53E); // 50% opacity for shadows

  /// Gradient for primary lime buttons
  static const limeGradient = LinearGradient(
    colors: [Color(0xFFC4F53E), Color(0xFFD4E53E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient for gold score
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFF7C13B), Color(0xFFF7D73B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient for board
  static const boardBackground = LinearGradient(
    colors: [ink900, ink800],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Score fill gradient (lime to teal)
  static const scoreFillGradient = LinearGradient(
    colors: [lime, teal],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
