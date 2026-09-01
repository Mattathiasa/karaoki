import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/ui_components.dart';

// ─── 1. Empty Queue ─────────────────────────────────────────────────────────
class EmptyQueueScreen extends StatelessWidget {
  final VoidCallback? onAddSong;
  const EmptyQueueScreen({super.key, this.onAddSong});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Dashed tile
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: KColors.ink700,
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  border: Border.all(
                    color: KColors.bone28,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.music_note, color: KColors.bone28, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nothing queued yet',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The board is waiting. Whoever adds the first song\nsings first.',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              KPrimaryButton(label: 'Add the first song', onPressed: onAddSong),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 2. No Results ──────────────────────────────────────────────────────────
class NoResultsScreen extends StatelessWidget {
  final String query;
  final VoidCallback? onTryGenre;
  const NoResultsScreen({super.key, required this.query, this.onTryGenre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Search field (red border)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: KColors.ink600,
                  borderRadius: BorderRadius.circular(KRadius.input),
                  border: Border.all(color: KColors.red, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: KColors.red, size: 18),
                    const SizedBox(width: 10),
                    Text(query, style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Icon(Icons.search_off, color: KColors.red, size: 40),
              const SizedBox(height: 16),
              Text(
                'No songs match "$query"',
                style: KTypography.displaySection.copyWith(color: KColors.bone),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your spelling or try a different search.',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 24),
              Text(
                'TRY INSTEAD',
                style: KTypography.monoLabel.copyWith(fontSize: 9),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Pop', 'Rock', 'Hip Hop', 'R&B'].map(
                  (g) => KCategoryPill(label: g, onTap: onTryGenre),
                ).toList(),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 3. Microphone Permission ───────────────────────────────────────────────
class MicPermissionScreen extends StatelessWidget {
  final VoidCallback? onAllow;
  final VoidCallback? onSkip;
  const MicPermissionScreen({super.key, this.onAllow, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Mic tile
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  gradient: const LinearGradient(colors: [KColors.lime, KColors.tangerine]),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic, color: KColors.onAccent, size: 24),
              ),
              const SizedBox(height: 24),
              const Text(
                'Karaoki needs your microphone',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We listen only while you are singing.\nNothing is recorded or uploaded.',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              KPrimaryButton(label: 'Allow microphone access', onPressed: onAllow),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onSkip,
                child: Text(
                  "Not now - I'll just watch",
                  style: KTypography.uiButton.copyWith(color: KColors.bone55, fontWeight: FontWeight.w400),
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

// ─── 4. Microphone Lost ─────────────────────────────────────────────────────
class MicLostScreen extends StatelessWidget {
  final VoidCallback? onReconnect;
  const MicLostScreen({super.key, this.onReconnect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Red banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: KColors.red.withOpacity(0.2),
              child: Row(
                children: [
                  KLiveDot(color: KColors.red, size: 6),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Microphone disconnected',
                          style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.red, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Scoring paused - the board is holding your slot',
                          style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Dimmed lyrics area
            Expanded(
              child: Opacity(
                opacity: 0.35,
                child: Padding(
                  padding: const EdgeInsets.all(KSpacing.massive),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Dancing in the neon midnight glow',
                        style: KTypography.uiBody.copyWith(fontSize: 15, color: KColors.bone28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We were never meant to last this long',
                        style: KTypography.displaySection.copyWith(fontSize: 32, color: KColors.bone28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'But here we are, just proving them wrong',
                        style: KTypography.uiBody.copyWith(fontSize: 18, color: KColors.bone28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Reconnecting indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'RECONNECTING',
                    style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45),
                  ),
                  const SizedBox(height: 8),
                  const _ReconnectingDots(),
                  const SizedBox(height: 20),
                  KSecondaryButton(label: 'Reconnect microphone', onPressed: onReconnect),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconnectingDots extends StatefulWidget {
  const _ReconnectingDots();
  @override
  State<_ReconnectingDots> createState() => _ReconnectingDotsState();
}

class _ReconnectingDotsState extends State<_ReconnectingDots> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _c, builder: (_, __) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) {
        final opacity = (_c.value * 3 - i).clamp(0.3, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8, height: 8,
          decoration: BoxDecoration(color: KColors.bone.withOpacity(opacity), shape: BoxShape.circle),
        );
      }));
    });
  }
}

// ─── 5. Weak Connection ─────────────────────────────────────────────────────
class WeakConnectionScreen extends StatelessWidget {
  const WeakConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Gold banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: KColors.gold.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(Icons.signal_wifi_off, color: KColors.gold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Weak connection - lyrics running locally, score syncs when you\'re back',
                      style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.gold),
                    ),
                  ),
                ],
              ),
            ),
            // Lyrics (full brightness)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.massive),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dancing in the neon midnight glow', style: KTypography.uiBody.copyWith(fontSize: 15, color: KColors.bone45)),
                    const SizedBox(height: 16),
                    Text('We were never meant to last this long', style: KTypography.displaySection.copyWith(fontSize: 32)),
                    const SizedBox(height: 16),
                    Text('But here we are, just proving them wrong', style: KTypography.uiBody.copyWith(fontSize: 18, color: KColors.bone45)),
                  ],
                ),
              ),
            ),
            // Latency + score syncing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _WeakMetric(label: 'LATENCY', value: '840ms'),
                  const SizedBox(width: 12),
                  _WeakMetric(label: 'SCORE', value: 'syncing…'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: KColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('◔ WEAK', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.gold)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: KSecondaryButton(label: 'Keep singing anyway', onPressed: () {}),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _WeakMetric extends StatelessWidget {
  final String label;
  final String value;
  const _WeakMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: KColors.gold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KRadius.tile),
          border: Border.all(color: KColors.gold.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.gold)),
            const SizedBox(height: 4),
            Text(value, style: KTypography.uiRowTitle.copyWith(fontSize: 14, color: KColors.gold)),
          ],
        ),
      ),
    );
  }
}

// ─── 6. Player Dropped ──────────────────────────────────────────────────────
class PlayerDroppedScreen extends StatelessWidget {
  final String playerName;
  final int holdSeconds;
  final VoidCallback? onSkip;
  final VoidCallback? onWait;

  PlayerDroppedScreen({
    super.key,
    required this.playerName,
    this.holdSeconds = 47,
    this.onSkip,
    this.onWait,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Red card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: KColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  border: Border.all(color: KColors.red.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      '$playerName dropped out',
                      style: KTypography.displaySection.copyWith(color: KColors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Holding their queue slot for 0:${holdSeconds.toString().padLeft(2, '0')}',
                      style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.red),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              KSecondaryButton(label: "Skip their slot", onPressed: onSkip),
              const SizedBox(height: 12),
              KSecondaryButton(label: 'Wait for them', onPressed: onWait),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 7. Room Full ───────────────────────────────────────────────────────────
class RoomFullScreen extends StatelessWidget {
  final int current;
  final int max;
  final VoidCallback? onSpectate;
  final VoidCallback? onNotify;

  const RoomFullScreen({
    super.key,
    this.current = 10,
    this.max = 10,
    this.onSpectate,
    this.onNotify,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.door_front_door, color: KColors.bone, size: 88),
              const SizedBox(height: 24),
              const Text(
                'This room is full',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$current of $max singers',
                style: KTypography.monoLabel.copyWith(fontSize: 11, color: KColors.bone45),
              ),
              const Spacer(flex: 2),
              KPrimaryButton(label: 'Spectate on the board', onPressed: onSpectate),
              const SizedBox(height: 12),
              KSecondaryButton(label: 'Notify me when free', onPressed: onNotify),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 8. Bad Code ────────────────────────────────────────────────────────────
class BadCodeScreen extends StatelessWidget {
  final String code;
  final VoidCallback? onAutofill;
  final VoidCallback? onTryAgain;
  final VoidCallback? onScan;

  const BadCodeScreen({
    super.key,
    required this.code,
    this.onAutofill,
    this.onTryAgain,
    this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Red field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: KColors.ink600,
                  borderRadius: BorderRadius.circular(KRadius.input),
                  border: Border.all(color: KColors.red, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  code.toUpperCase(),
                  style: KTypography.monoCode.copyWith(fontSize: 30, color: KColors.red, letterSpacing: 0.14),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No room with that code.',
                style: KTypography.displaySection.copyWith(color: KColors.red),
              ),
              const SizedBox(height: 8),
              Text(
                'Codes look like KARA-7821.',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
              ),
              const Spacer(flex: 2),
              KPrimaryButton(label: 'Try again', onPressed: onTryAgain),
              const SizedBox(height: 12),
              KSecondaryButton(label: 'Autofill the demo code', onPressed: onAutofill),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onScan,
                child: Text(
                  'Scan instead',
                  style: KTypography.uiButton.copyWith(color: KColors.bone55, fontWeight: FontWeight.w400),
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

// ─── 9. Unavailable Song ────────────────────────────────────────────────────
class UnavailableSongScreen extends StatelessWidget {
  final String songTitle;
  final List<String> alternatives;
  const UnavailableSongScreen({super.key, required this.songTitle, this.alternatives = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Desaturated art with 🚫
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  color: KColors.ink700,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.block, color: KColors.bone28, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Not available in your region',
                style: KTypography.displaySection.copyWith(color: KColors.bone),
              ),
              if (alternatives.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Try these instead - the room has sung them before:',
                  style: KTypography.uiBody.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 12),
                ...alternatives.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: KCategoryPill(label: a, onTap: () {}),
                )),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 10. No History ─────────────────────────────────────────────────────────
class NoHistoryScreen extends StatelessWidget {
  final VoidCallback? onPickSong;
  const NoHistoryScreen({super.key, this.onPickSong});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: KColors.ink700,
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  border: Border.all(color: KColors.bone28, width: 2, style: BorderStyle.solid),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic_off, color: KColors.bone28, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'No performances yet',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: KColors.bone,
                ),
              ),
              const Spacer(flex: 3),
              KPrimaryButton(label: 'Pick your first song', onPressed: onPickSong),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 11. No Badges ──────────────────────────────────────────────────────────
class NoBadgesScreen extends StatelessWidget {
  const NoBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: KColors.ink700,
                  borderRadius: BorderRadius.circular(KRadius.heroCard),
                  border: Border.all(color: KColors.bone28, width: 2, style: BorderStyle.solid),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.lock, color: KColors.bone28, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'First Song',
                style: KTypography.displaySection.copyWith(color: KColors.bone),
              ),
              const SizedBox(height: 8),
              Text(
                'One performance away',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 12. Waiting ────────────────────────────────────────────────────────────
class WaitingScreen extends StatelessWidget {
  final int playersPicking;
  const WaitingScreen({super.key, this.playersPicking = 2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const Text(
                'Waiting for the room',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$playersPicking players still picking songs',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 32),
              const _WaitingDots(),
              const Spacer(flex: 3),
              KSecondaryButton(label: 'Start anyway', onPressed: () {}),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaitingDots extends StatefulWidget {
  const _WaitingDots();
  @override
  State<_WaitingDots> createState() => _WaitingDotsState();
}

class _WaitingDotsState extends State<_WaitingDots> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _c, builder: (_, __) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) {
        final opacity = ((_c.value * 3 - i) % 3).clamp(0.3, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10, height: 10,
          decoration: BoxDecoration(color: KColors.lime.withOpacity(opacity), shape: BoxShape.circle),
        );
      }));
    });
  }
}
