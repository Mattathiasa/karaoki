import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

// ─── Battle Mode ────────────────────────────────────────────────────────────
class BattleScreen extends StatelessWidget {
  final String playerAName;
  final String playerAInitial;
  final int playerAScore;
  final String playerBName;
  final String playerBInitial;
  final int playerBScore;
  final int round;
  final int totalRounds;
  final String songTitle;
  final VoidCallback? onAccept;
  final VoidCallback? onBack;

  const BattleScreen({
    super.key,
    this.playerAName = 'Matt',
    this.playerAInitial = 'M',
    this.playerAScore = 87,
    this.playerBName = 'Sara',
    this.playerBInitial = 'S',
    this.playerBScore = 82,
    this.round = 3,
    this.totalRounds = 5,
    this.songTitle = 'Neon Midnight',
    this.onAccept,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH, vertical: 16),
              child: Text(
                'BATTLE MODE · ROUND $round',
                style: KTypography.monoLabel.copyWith(fontSize: 10, letterSpacing: 0.2),
              ),
            ),

            // Split
            Expanded(
              child: Column(
                children: [
                  // Player A (red tint)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: KColors.red.withOpacity(0.08),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KAvatar(initial: playerAInitial, size: 56),
                          const SizedBox(height: 12),
                          Text(
                            playerAName,
                            style: const TextStyle(
                              fontFamily: 'BricolageGrotesque',
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
                              color: KColors.bone,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LV 24 · 3 wins',
                            style: KTypography.monoLabel.copyWith(fontSize: 10),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$playerAScore',
                            style: KTypography.displayHeadline2.copyWith(fontSize: 34, color: KColors.tangerine),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // VS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KColors.red.withOpacity(0.3), KColors.teal.withOpacity(0.3)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w800,
                        fontSize: 52,
                        color: KColors.bone,
                      ),
                    ),
                  ),

                  // Player B (teal tint)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: KColors.teal.withOpacity(0.08),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KAvatar(initial: playerBInitial, size: 56),
                          const SizedBox(height: 12),
                          Text(
                            playerBName,
                            style: const TextStyle(
                              fontFamily: 'BricolageGrotesque',
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
                              color: KColors.bone,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LV 18 · 2 wins',
                            style: KTypography.monoLabel.copyWith(fontSize: 10),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$playerBScore',
                            style: KTypography.displayHeadline2.copyWith(fontSize: 34, color: KColors.teal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Song card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KColors.ink650,
                  borderRadius: BorderRadius.circular(KRadius.tile),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: KColors.ink700,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.music_note, color: KColors.bone28, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(songTitle, style: KTypography.uiRowTitle.copyWith(fontSize: 13)),
                          Text('Battle Track', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  KPrimaryButton(label: 'Accept the battle', onPressed: onAccept),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onBack,
                    child: Text(
                      'Back to lobby',
                      style: KTypography.uiButton.copyWith(color: KColors.bone55, fontWeight: FontWeight.w400, fontSize: 13),
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

// ─── Team Battle ────────────────────────────────────────────────────────────
class TeamScreen extends StatelessWidget {
  final int fireScore;
  final int lightningScore;
  final int songNumber;
  final int totalSongs;
  final String currentSinger;
  final String currentTeam;
  final List<TeamPlayer> firePlayers;
  final List<TeamPlayer> lightningPlayers;

  const TeamScreen({
    super.key,
    this.fireScore = 184,
    this.lightningScore = 167,
    this.songNumber = 3,
    this.totalSongs = 6,
    this.currentSinger = 'Matt',
    this.currentTeam = 'FIRE',
    this.firePlayers = const [],
    this.lightningPlayers = const [],
  });

  @override
  Widget build(BuildContext context) {
    final total = fireScore + lightningScore;
    final fireRatio = total > 0 ? fireScore / total : 0.5;

    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH, vertical: 16),
              child: Text(
                'TEAM BATTLE · SONG $songNumber OF $totalSongs',
                style: KTypography.monoLabel.copyWith(fontSize: 10, letterSpacing: 0.2),
              ),
            ),

            // Team cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _TeamCard(
                    icon: Icons.local_fire_department, name: 'TEAM FIRE', score: fireScore, color: KColors.tangerine,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _TeamCard(
                    icon: Icons.bolt, name: 'TEAM LIGHTNING', score: lightningScore, color: KColors.teal,
                  )),
                ],
              ),
            ),

            // Split bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(fireRatio * 100).round()}%', style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.tangerine)),
                      Text('${((1 - fireRatio) * 100).round()}%', style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.teal)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (fireRatio * 1000).round(),
                            child: Container(color: KColors.tangerine),
                          ),
                          Expanded(
                            flex: ((1 - fireRatio) * 1000).round(),
                            child: Container(color: KColors.teal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Singing now card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KColors.tangerine.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KRadius.tile),
                  border: Border.all(color: KColors.tangerine.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  'SINGING NOW · TEAM $currentTeam',
                  style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.tangerine, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const Spacer(),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: KPrimaryButton(label: 'You sing next for Fire', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final int score;
  final Color color;

  const _TeamCard({required this.icon, required this.name, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KRadius.tile),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(name, style: KTypography.monoLabel.copyWith(fontSize: 9, color: color)),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: TextStyle(
              fontFamily: 'BricolageGrotesque',
              fontWeight: FontWeight.w800,
              fontSize: 34,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class TeamPlayer {
  final String name;
  final bool isSinging;
  const TeamPlayer({required this.name, this.isSinging = false});
}

// ─── Duet ───────────────────────────────────────────────────────────────────
class DuetScreen extends StatelessWidget {
  final String playerAName;
  final String playerBName;
  final int scoreA;
  final int scoreB;

  const DuetScreen({
    super.key,
    this.playerAName = 'Matt',
    this.playerBName = 'Sara',
    this.scoreA = 87,
    this.scoreB = 84,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: KColors.limeTint,
                      borderRadius: BorderRadius.circular(KRadius.pill),
                    ),
                    child: Text('A · ${playerAName.toUpperCase()}', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.lime)),
                  ),
                  const SizedBox(width: 16),
                  Text('DUET', style: KTypography.monoLabel.copyWith(fontSize: 10, letterSpacing: 0.2)),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: KColors.teal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(KRadius.pill),
                    ),
                    child: Text('B · ${playerBName.toUpperCase()}', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.teal)),
                  ),
                ],
              ),
            ),

            // Lyrics
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: KSpacing.massive),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Part A
                    _DuetLine(text: 'We were never meant to last this long', part: 'A'),
                    SizedBox(height: 12),
                    // Part B
                    _DuetLine(text: 'Dancing in the neon midnight glow', part: 'B'),
                    SizedBox(height: 12),
                    // Both
                    _DuetLine(text: 'This is our neon midnight', part: 'BOTH'),
                    SizedBox(height: 12),
                    _DuetLine(text: "But here we are, just proving them wrong", part: 'A', dimmed: true),
                  ],
                ),
              ),
            ),

            // Footer scores
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: KColors.hairline, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('A $scoreA', style: KTypography.monoLabel.copyWith(fontSize: 12, color: KColors.lime))),
                  Container(width: 1, height: 20, color: KColors.hairline),
                  Expanded(child: Text('B $scoreB', style: KTypography.monoLabel.copyWith(fontSize: 12, color: KColors.teal))),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: KPrimaryButton(label: 'Finish duet', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuetLine extends StatelessWidget {
  final String text;
  final String part;
  final bool dimmed;

  const _DuetLine({required this.text, required this.part, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final isBoth = part == 'BOTH';
    final color = isBoth ? null : (part == 'A' ? KColors.lime : KColors.teal);

    return Opacity(
      opacity: dimmed ? 0.6 : 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isBoth ? null : (color ?? KColors.lime).withOpacity(0.12),
          border: Border(
            left: BorderSide(
              color: isBoth ? KColors.hairline : (color ?? KColors.lime),
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: KTypography.displaySection.copyWith(
            fontSize: isBoth ? 22 : 19,
            color: isBoth ? KColors.bone : (color ?? KColors.bone),
          ),
          textAlign: isBoth ? TextAlign.center : TextAlign.left,
        ),
      ),
    );
  }
}

// ─── Pass the Mic ───────────────────────────────────────────────────────────
class PassMicScreen extends StatelessWidget {
  final int sectionNumber;
  final int totalSections;
  final String nextSinger;
  final int linesUntil;
final List<PassPlayer> players;

  const PassMicScreen({
    super.key,
    this.sectionNumber = 3,
    this.totalSections = 6,
    this.nextSinger = 'Matt',
    this.linesUntil = 2,
    this.players = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH, vertical: 16),
              child: Text(
                'PASS THE MIC · SECTION $sectionNumber OF $totalSections',
                style: KTypography.monoLabel.copyWith(fontSize: 10, letterSpacing: 0.2),
              ),
            ),

            // Big alert card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [KColors.limeTint.withOpacity(0.3), KColors.ink650],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  border: Border.all(color: KColors.limeTint.withOpacity(0.3), width: 0.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'GET READY, ${nextSinger.toUpperCase()}!',
                      style: KTypography.monoLabel.copyWith(fontSize: 11, color: KColors.lime, letterSpacing: 0.16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$linesUntil LINES',
                      style: const TextStyle(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w800,
                        fontSize: 40,
                        color: KColors.lime,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'until the mic passes to you',
                      style: KTypography.uiBody.copyWith(fontSize: 14.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _PassRow(label: 'DONE', score: 91, color: KColors.mint, done: true),
                  SizedBox(height: 8),
                  _PassRow(label: 'SINGING', score: 0, color: KColors.teal, active: true),
                  SizedBox(height: 8),
                  _PassRow(label: 'NEXT', score: 0, color: KColors.lime, isNext: true),
                  SizedBox(height: 8),
                  _PassRow(label: 'QUEUED', score: 0, color: KColors.bone28, queued: true),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: KPrimaryButton(label: 'Take the mic', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassRow extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool done;
  final bool active;
  final bool isNext;
  final bool queued;

  const _PassRow({
    required this.label,
    required this.score,
    required this.color,
    this.done = false,
    this.active = false,
    this.isNext = false,
    this.queued = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? KColors.limeTint.withOpacity(0.2)
            : active
                ? KColors.teal.withOpacity(0.15)
                : KColors.ink650,
        borderRadius: BorderRadius.circular(KRadius.tile),
        border: Border.all(
          color: isNext ? KColors.lime : active ? KColors.teal : KColors.hairline,
          width: isNext || active ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(label, style: KTypography.monoLabel.copyWith(fontSize: 9, color: color)),
          const Spacer(),
          if (done) Text('$score', style: KTypography.monoLabel.copyWith(fontSize: 12, color: KColors.mint)),
          if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: KColors.lime, borderRadius: BorderRadius.circular(999)),
              child: Text('NEXT', style: KTypography.monoLabel.copyWith(fontSize: 8, color: KColors.onAccent, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class PassPlayer {
  final String name;
  const PassPlayer({required this.name});
}
