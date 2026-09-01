import 'package:flutter/material.dart';
import 'colors.dart';

/// Karaoki design system typography
class KTypography {
  KTypography._();

  // Font families
  static const String displayFamily = 'BricolageGrotesque';
  static const String uiFamily = 'InstrumentSans';
  static const String monoFamily = 'SpaceMono';

  // Mobile scale
  static const double heroMobile = 34;
  static const double headline2Mobile = 26;
  static const double sectionHeroMobile = 22;
  static const double buttonMobile = 15.5;
  static const double rowTitleMobile = 13.5;
  static const double bodyMobile = 12.5;
  static const double metaMobile = 11;
  static const double monoLabelMobile = 9.5;

  // Board scale
  static const double finalScoreBoard = 206;
  static const double roomCodeBoard = 94;
  static const double currentLyricBoard = 58;
  static const double nextLyricBoard = 33;
  static const double headline1Board = 48;
  static const double headline2Board = 26;
  static const double nameBoard = 22;
  static const double monoBoard = 14;

  // Display styles (Bricolage Grotesque)
  static const TextStyle displayHero = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w800,
    fontSize: heroMobile,
    color: KColors.bone,
    letterSpacing: -1.2,
    height: 1.1,
  );

  static const TextStyle displayHeadline2 = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: headline2Mobile,
    color: KColors.bone,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle displaySection = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: sectionHeroMobile,
    color: KColors.bone,
    letterSpacing: -0.6,
    height: 1.2,
  );

  // UI styles (Instrument Sans)
  static const TextStyle uiButton = TextStyle(
    fontFamily: uiFamily,
    fontWeight: FontWeight.w700,
    fontSize: buttonMobile,
    color: KColors.bone,
    height: 1.3,
  );

  static const TextStyle uiRowTitle = TextStyle(
    fontFamily: uiFamily,
    fontWeight: FontWeight.w600,
    fontSize: rowTitleMobile,
    color: KColors.bone,
    height: 1.3,
  );

  static const TextStyle uiBody = TextStyle(
    fontFamily: uiFamily,
    fontWeight: FontWeight.w400,
    fontSize: bodyMobile,
    color: KColors.bone55,
    height: 1.55,
  );

  // Mono styles (Space Mono)
  static const TextStyle monoLabel = TextStyle(
    fontFamily: monoFamily,
    fontWeight: FontWeight.w400,
    fontSize: monoLabelMobile,
    color: KColors.bone45,
    letterSpacing: 0.16,
    height: 1.4,
  );

  static const TextStyle monoCode = TextStyle(
    fontFamily: monoFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: KColors.bone,
    letterSpacing: 0.14,
    height: 1.3,
  );

  // Board-specific styles
  static const TextStyle boardHero = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w800,
    fontSize: finalScoreBoard,
    color: KColors.gold,
    letterSpacing: -9,
    height: 1.0,
  );

  static const TextStyle boardRoomCode = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w800,
    fontSize: roomCodeBoard,
    color: KColors.lime,
    letterSpacing: -4,
    height: 1.0,
  );

  static const TextStyle boardLyricCurrent = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: currentLyricBoard,
    color: KColors.bone,
    letterSpacing: -2,
    height: 1.1,
  );

  static const TextStyle boardLyricNext = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w400,
    fontSize: nextLyricBoard,
    color: KColors.bone45,
    letterSpacing: -1,
    height: 1.2,
  );

  static const TextStyle boardMono = TextStyle(
    fontFamily: monoFamily,
    fontWeight: FontWeight.w400,
    fontSize: monoBoard,
    color: KColors.bone45,
    letterSpacing: 0.16,
    height: 1.3,
  );
}
