import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../providers/app_state.dart';
import '../../services/performance_history_service.dart';

class CompleteScreen extends StatefulWidget {
  final int score;
  final int pitch;
  final int timing;
  final int consistency;
  final int energy;
  final int speed;
  final bool isNewBest;
  final int previousBest;
  final VoidCallback? onContinue;
  final VoidCallback? onLeaderboard;

  const CompleteScreen({
    super.key,
    this.score = 87,
    this.pitch = 92,
    this.timing = 88,
    this.consistency = 81,
    this.energy = 95,
    this.speed = 78,
    this.isNewBest = true,
    this.previousBest = 87,
    this.onContinue,
    this.onLeaderboard,
  });

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  bool _savedToHistory = false;

  @override
  Widget build(BuildContext context) {
    // Delegates to the shared build so state changes (saved flag) reflect.
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    // Prefer the real breakdown from the performance that just ended; fall
    // back to the constructor defaults when there is none (e.g. deep-linked
    // straight to /complete).
    final breakdown = context.watch<AppState>().lastBreakdown;
    final effectiveScore = breakdown?.overall ?? widget.score;
    final effectivePitch = breakdown?.pitch ?? widget.pitch;
    final effectiveTiming = breakdown?.timing ?? widget.timing;
    final effectiveConsistency = breakdown?.consistency ?? widget.consistency;
    final effectiveEnergy = breakdown?.energy ?? widget.energy;
    final effectiveSpeed = breakdown?.speed ?? widget.speed;
    final effectiveNewBest = breakdown == null ? widget.isNewBest : effectiveScore > widget.previousBest;

    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: KSpacing.mobilePaddingH,
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Score
              KScoreBadge(score: effectiveScore),
              const SizedBox(height: 12),
              // Rank
              KRankBadge(rank: effectiveScore >= 90 ? 'SUPERSTAR' : 'GREAT'),
              const SizedBox(height: 12),
              // Personal best
              if (effectiveNewBest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: KColors.mint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(KRadius.pill),
                  ),
                  child: Text(
                    '★ NEW PERSONAL BEST · +${effectiveScore - widget.previousBest} FROM LAST TIME',
                    style: KTypography.monoLabel.copyWith(
                      fontSize: 9,
                      color: KColors.mint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              // Breakdown
              _BreakdownBar(label: 'PITCH', value: effectivePitch, color: KColors.mint),
              const SizedBox(height: 10),
              _BreakdownBar(label: 'TIMING', value: effectiveTiming, color: KColors.gold),
              const SizedBox(height: 10),
              _BreakdownBar(
                label: 'CONSISTENCY',
                value: effectiveConsistency,
                color: KColors.teal,
              ),
              const SizedBox(height: 10),
              _BreakdownBar(label: 'ENERGY', value: effectiveEnergy, color: KColors.lime),
              const SizedBox(height: 10),
              _BreakdownBar(label: 'SPEED', value: effectiveSpeed, color: KColors.tangerine),
              const SizedBox(height: 32),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: KSecondaryButton(
                      label: 'Share',
                      icon: const Icon(Icons.share, color: KColors.bone, size: 16),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KSecondaryButton(
                      label: _savedToHistory ? 'Saved ✓' : 'Save',
                      icon: Icon(
                        _savedToHistory ? Icons.check_circle : Icons.save,
                        color: KColors.bone,
                        size: 16,
                      ),
                      onPressed: _savedToHistory ? null : () => _saveToHistory(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              KPrimaryButton(
                label: 'See the leaderboard',
                onPressed: widget.onLeaderboard,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: widget.onContinue,
                child: Text(
                  'Continue singing',
                  style: KTypography.uiButton.copyWith(
                    color: KColors.bone55,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Write this performance to history (performances/{id} in the realtime
  /// database). No-ops with a notice when persistence is unavailable.
  Future<void> _saveToHistory() async {
    final appState = context.read<AppState>();
    final breakdown = appState.lastBreakdown;
    if (breakdown == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to save yet.')),
      );
      return;
    }
    final saved = await context.read<PerformanceHistoryService>().savePerformance(
      PerformanceRecord(
        songId: appState.currentSong?.id ?? '',
        songTitle: appState.currentSong?.title ?? 'Unknown song',
        singerId: appState.userId,
        score: breakdown.overall,
        pitch: breakdown.pitch,
        timing: breakdown.timing,
        consistency: breakdown.consistency,
        energy: breakdown.energy,
        speed: breakdown.speed,
        roomId: appState.currentRoom?.id,
        performedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    if (saved != null) {
      setState(() => _savedToHistory = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('History saving needs Firebase — not configured yet.'),
        ),
      );
    }
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _BreakdownBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: KTypography.monoLabel.copyWith(
                fontSize: 9,
                color: KColors.bone45,
              ),
            ),
            Text(
              '$value%',
              style: KTypography.uiRowTitle.copyWith(
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: KColors.ink600,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
