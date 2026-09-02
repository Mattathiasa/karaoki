import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/lyrics.dart';
import '../../widgets/ui_components.dart';
import '../../services/performance_service.dart';
import '../../services/karaoke_playback_service.dart';
import '../../models/song.dart';

class SingingScreen extends StatefulWidget {
  final PerformanceService? perfService;
  final VoidCallback? onComplete;

  const SingingScreen({super.key, this.perfService, this.onComplete});

  @override
  State<SingingScreen> createState() => _SingingScreenState();
}

class _SingingScreenState extends State<SingingScreen> {
  PerformanceState? _state;
  Stream<KaraokeState>? _karaokeStream;
  KaraokePlaybackService? _karaoke;

  @override
  void initState() {
    super.initState();
    // Wire up legacy PerformanceService
    if (widget.perfService != null) {
      widget.perfService!.stream.listen((state) {
        if (mounted) {
          setState(() => _state = state);
          if (state.isComplete) widget.onComplete?.call();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_karaokeStream == null) {
      _karaoke = Provider.of<KaraokePlaybackService>(context, listen: false);
      // Load fixture song and start simulated playback
      _karaoke!.loadSong(fixtureSongs.first);
      _karaoke!.playSimulated();
      _karaokeStream = _karaoke!.stateStream;
    }
  }

  @override
  void dispose() {
    _karaoke?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try KaraokePlaybackService first, fall back to PerformanceService
    if (_karaokeStream != null) {
      return StreamBuilder<KaraokeState>(
        stream: _karaokeStream,
        builder: (context, snapshot) {
          final ks = snapshot.data;
          if (ks != null) {
            return _buildFromKaraoke(ks);
          }
          return _buildFallback();
        },
      );
    }
    return _buildFallback();
  }

  Widget _buildFromKaraoke(KaraokeState ks) {
    final previousLine = ks.previousLine;
    final currentLine = ks.currentLine.isNotEmpty ? ks.currentLine : '...';
    final nextLine = ks.nextLine;
    final lineProgress = ks.lineProgress;
    final progress = ks.overallProgress;
    final pitch = ks.pitch;
    final timing = ks.timing;
    final combo = ks.combo;
    final score = ks.score;
    final elapsed = ks.positionLabel;
    final duration = ks.durationLabel;

    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            // Top: singing status bar
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, KSpacing.mobilePaddingV, KSpacing.mobilePaddingH, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: KColors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(KRadius.pill)),
                    child: Row(children: [
                      const KLiveDot(color: KColors.red, size: 6),
                      const SizedBox(width: 6),
                      Text('YOU ARE SINGING', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.red, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const Spacer(),
                  const KIconButton(icon: Icons.pause, size: 34),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 0),
              child: Row(children: [
                Text(elapsed, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45)),
                const SizedBox(width: 10),
                Expanded(child: KProgressBar(progress: progress, height: 5)),
                const SizedBox(width: 10),
                Text(duration, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45)),
              ]),
            ),

            // Lyrics (dominant centre)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KSpacing.massive),
                child: KLyricWidget(
                  previousLine: previousLine,
                  currentLine: currentLine,
                  nextLine: nextLine,
                  lineProgress: lineProgress,
                ),
              ),
            ),

            // Input equaliser
            const SizedBox(height: 52, child: KEqualiser(height: 52, barCount: 18)),

            // Metrics
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 0),
              child: Row(children: [
                _MetricCard(label: 'PITCH', value: '$pitch%', color: KColors.mint),
                const SizedBox(width: 8),
                _MetricCard(label: 'TIMING', value: '$timing%', color: KColors.gold),
                const SizedBox(width: 8),
                _MetricCard(label: 'COMBO', value: 'x$combo', color: KColors.lime),
              ]),
            ),

            // Live score
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 10, KSpacing.mobilePaddingH, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: KColors.limeTint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(KRadius.tile),
                  border: Border.all(color: KColors.limeTint.withOpacity(0.3), width: 0.5),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('LIVE SCORE', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.bone45)),
                  Text('$score', style: KTypography.displayHeadline2.copyWith(fontSize: 26, color: KColors.lime)),
                ]),
              ),
            ),

            // End performance link
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Text('End performance \u2192', style: KTypography.uiButton.copyWith(color: KColors.bone55, fontWeight: FontWeight.w400, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback to legacy PerformanceService data
  Widget _buildFallback() {
    final state = _state;
    final previousLine = state?.previousLine ?? 'Dancing in the neon midnight glow';
    final currentLine = state?.currentLine ?? 'We were never meant to last this long';
    final nextLine = state?.nextLine ?? 'But here we are, just proving them wrong';
    final lineProgress = state?.lineProgress ?? 0.65;
    final progress = state?.progress ?? 0.42;
    final pitch = state?.pitch ?? 88;
    final timing = state?.timing ?? 85;
    final combo = state?.combo ?? 12;
    final score = state?.score ?? 87;
    final elapsed = state?.elapsedLabel ?? '1:32';
    final duration = state?.durationLabel ?? '3:42';

    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, KSpacing.mobilePaddingV, KSpacing.mobilePaddingH, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: KColors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(KRadius.pill)),
                    child: Row(children: [
                      const KLiveDot(color: KColors.red, size: 6),
                      const SizedBox(width: 6),
                      Text('YOU ARE SINGING', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.red, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const Spacer(),
                  const KIconButton(icon: Icons.pause, size: 34),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 0),
              child: Row(children: [
                Text(elapsed, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45)),
                const SizedBox(width: 10),
                Expanded(child: KProgressBar(progress: progress, height: 5)),
                const SizedBox(width: 10),
                Text(duration, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45)),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KSpacing.massive),
                child: KLyricWidget(
                  previousLine: previousLine,
                  currentLine: currentLine,
                  nextLine: nextLine,
                  lineProgress: lineProgress,
                ),
              ),
            ),
            const SizedBox(height: 52, child: KEqualiser(height: 52, barCount: 18)),
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 12, KSpacing.mobilePaddingH, 0),
              child: Row(children: [
                _MetricCard(label: 'PITCH', value: '$pitch%', color: KColors.mint),
                const SizedBox(width: 8),
                _MetricCard(label: 'TIMING', value: '$timing%', color: KColors.gold),
                const SizedBox(width: 8),
                _MetricCard(label: 'COMBO', value: 'x$combo', color: KColors.lime),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, 10, KSpacing.mobilePaddingH, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: KColors.limeTint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(KRadius.tile),
                  border: Border.all(color: KColors.limeTint.withOpacity(0.3), width: 0.5),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('LIVE SCORE', style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.bone45)),
                  Text('$score', style: KTypography.displayHeadline2.copyWith(fontSize: 26, color: KColors.lime)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Text('End performance \u2192', style: KTypography.uiButton.copyWith(color: KColors.bone55, fontWeight: FontWeight.w400, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KRadius.tile),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Column(children: [
          Text(label, style: KTypography.monoLabel.copyWith(fontSize: 9, color: color)),
          const SizedBox(height: 4),
          Text(value, style: KTypography.displayHeadline2.copyWith(fontSize: 16, color: color)),
        ]),
      ),
    );
  }
}
