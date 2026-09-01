import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../widgets/cards.dart';

class BoardVsScreen extends StatelessWidget {
  final String playerAName;
  final String playerAInitial;
  final int playerAScore;
  final int playerAPitch;
  final int playerACombo;
  final String playerBName;
  final String playerBInitial;
  final int playerBScore;
  final int playerBPitch;
  final int playerBCombo;
  final String songTitle;
  final int teamFireScore;
  final int teamLightningScore;

  const BoardVsScreen({
    super.key,
    this.playerAName = 'Matt',
    this.playerAInitial = 'M',
    this.playerAScore = 87,
    this.playerAPitch = 88,
    this.playerACombo = 12,
    this.playerBName = 'Sara',
    this.playerBInitial = 'S',
    this.playerBScore = 82,
    this.playerBPitch = 85,
    this.playerBCombo = 9,
    required this.songTitle,
    this.teamFireScore = 184,
    this.teamLightningScore = 167,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink900,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x18F76242), KColors.ink900, Color(0x185FDCE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.boardPadding, 24, KSpacing.boardPadding, 0),
              child: Row(
                children: [
                  Text(
                    'BATTLE MODE · FINAL ROUND · $songTitle',
                    style: KTypography.boardMono.copyWith(fontSize: 14, letterSpacing: 0.32),
                  ),
                ],
              ),
            ),

            // Three columns
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KSpacing.boardPadding, vertical: 24),
                child: Row(
                  children: [
                    // Player A
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Bloom
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KColors.tangerine.withOpacity(0.2),
                                  boxShadow: [
                                    BoxShadow(color: KColors.tangerine.withOpacity(0.4), blurRadius: 70, spreadRadius: 20),
                                  ],
                                ),
                              ),
                              KAvatar(initial: playerAInitial, size: 150),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            playerAName,
                            style: const TextStyle(
                              fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                              fontSize: 64, color: KColors.bone,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$playerAScore',
                            style: TextStyle(
                              fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
                              fontSize: 96, color: KColors.tangerine,
                              shadows: [BoxShadow(color: KColors.tangerine.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PITCH $playerAPitch%  x$playerACombo',
                            style: KTypography.boardMono.copyWith(fontSize: 13, color: KColors.tangerine),
                          ),
                        ],
                      ),
                    ),

                    // VS
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'VS',
                          style: TextStyle(
                            fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
                            fontSize: 96, color: KColors.bone,
                          ),
                        ),
                      ],
                    ),

                    // Player B
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 150, height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KColors.teal.withOpacity(0.2),
                                  boxShadow: [BoxShadow(color: KColors.teal.withOpacity(0.4), blurRadius: 70, spreadRadius: 20)],
                                ),
                              ),
                              KAvatar(initial: playerBInitial, size: 150),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            playerBName,
                            style: const TextStyle(
                              fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                              fontSize: 64, color: KColors.bone,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$playerBScore',
                            style: TextStyle(
                              fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
                              fontSize: 96, color: KColors.teal,
                              shadows: [BoxShadow(color: KColors.teal.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PITCH $playerBPitch%  x$playerBCombo',
                            style: KTypography.boardMono.copyWith(fontSize: 13, color: KColors.teal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer: team aggregate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.boardPadding, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: KColors.hairline, width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TeamPill(label: 'TEAM FIRE', score: teamFireScore, color: KColors.tangerine),
                  const SizedBox(width: 20),
                  _TeamPill(label: 'TEAM LIGHTNING', score: teamLightningScore, color: KColors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamPill extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _TeamPill({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Text(label, style: KTypography.boardMono.copyWith(fontSize: 13, color: color)),
          const SizedBox(width: 12),
          Text(
            '$score',
            style: TextStyle(
              fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w800,
              fontSize: 22, color: color,
            ),
          ),
        ],
      ),
    );
  }
}
