import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../widgets/lyrics.dart';
import '../../widgets/cards.dart';
import '../../widgets/ui_components.dart';
import '../../services/karaoke_playback_service.dart';
import '../../models/song.dart';

/// Board/TV performance screen — shows large lyrics, pitch gauge, score, combo.
/// Subscribes to [KaraokePlaybackService] for real-time lyric sync and scoring.
class BoardPerformanceScreen extends StatefulWidget {
  const BoardPerformanceScreen({super.key});

  @override
  State<BoardPerformanceScreen> createState() => _BoardPerformanceScreenState();
}

class _BoardPerformanceScreenState extends State<BoardPerformanceScreen>
    with SingleTickerProviderStateMixin {
  late final KaraokePlaybackService _playback;
  KaraokeState _state = const KaraokeState(song: Song(
    id: '', title: '', artist: '', genre: '', difficulty: '',
    duration: Duration.zero,
  ));
  Stream<KaraokeState>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) {
      _playback = Provider.of<KaraokePlaybackService>(context, listen: false);
      // Load the first fixture song and start simulated playback
      _playback.loadSong(fixtureSongs.first);
      _playback.playSimulated();
      _stream = _playback.stateStream;
    }
  }

  @override
  void dispose() {
    _playback.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KaraokeState>(
      stream: _stream,
      initialData: _state,
      builder: (context, snapshot) {
        final s = snapshot.data ?? _state;
        _state = s;
        return _buildScreen(s);
      },
    );
  }

  Widget _buildScreen(KaraokeState s) {
    return Scaffold(
      backgroundColor: KColors.ink900,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              KColors.limeTint.withOpacity(0.2),
              KColors.ink900,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.boardPadding,
                24,
                KSpacing.boardPadding,
                0,
              ),
              child: Row(
                children: [
                  // Cover art
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [KColors.limeTint, KColors.ink700],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.music_note, color: KColors.bone28, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Song info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.song.title,
                        style: const TextStyle(
                          fontFamily: 'BricolageGrotesque',
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                          color: KColors.bone,
                        ),
                      ),
                      Text(
                        '${s.song.artist} \u00b7 ${s.song.genre}',
                        style: KTypography.boardMono.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // LIVE pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const KLiveDot(color: KColors.red, size: 6),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: KTypography.boardMono.copyWith(
                            fontSize: 13,
                            color: KColors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mode pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.ink600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'CLASSIC',
                      style: KTypography.boardMono.copyWith(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: KColors.ink600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${s.positionLabel} / ${s.durationLabel}',
                      style: KTypography.boardMono.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 16, 44, 0),
              child: KProgressBar(progress: s.overallProgress, height: 5),
            ),

            // Lyrics (dominant centre)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSpacing.boardPadding * 2,
                ),
                child: s.currentLine.isNotEmpty
                    ? KBoardLyricWidget(
                        previousLine: s.previousLine,
                        currentLine: s.currentLine,
                        nextLine: s.nextLine,
                        lineProgress: s.lineProgress,
                      )
                    : const Center(
                        child: Text(
                          '...',
                          style: TextStyle(
                            fontFamily: 'BricolageGrotesque',
                            fontSize: 64,
                            color: KColors.bone28,
                          ),
                        ),
                      ),
              ),
            ),

            // Bottom rail (4 columns)
            Container(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.boardPadding,
                16,
                KSpacing.boardPadding,
                0,
              ),
              child: Row(
                children: [
                  // Now singing
                  const _BottomColumn(
                    label: '01 / NOW SINGING',
                    child: Row(
                      children: [
                        KAvatar(initial: 'M', size: 50),
                        SizedBox(width: 12),
                        Text(
                          'Matt',
                          style: TextStyle(
                            fontFamily: 'BricolageGrotesque',
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                            color: KColors.bone,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Live score
                  _BottomColumn(
                    label: '02 / LIVE SCORE',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: KColors.limeTint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${s.score}',
                        style: const TextStyle(
                          fontFamily: 'BricolageGrotesque',
                          fontWeight: FontWeight.w800,
                          fontSize: 44,
                          color: KColors.lime,
                        ),
                      ),
                    ),
                  ),
                  // Pitch track
                  _BottomColumn(
                    label: '03 / PITCH TRACK',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'PITCH ${s.pitch}%',
                              style: KTypography.boardMono.copyWith(fontSize: 13),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'TIMING ${s.timing}%',
                              style: KTypography.boardMono.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          height: 50,
                          child: KEqualiser(height: 50, barCount: 18),
                        ),
                      ],
                    ),
                  ),
                  // Combo
                  _BottomColumn(
                    label: '04 / COMBO',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.whatshot, color: KColors.gold, size: 34),
                        const SizedBox(width: 8),
                        Text(
                          'x${s.combo}',
                          style: const TextStyle(
                            fontFamily: 'BricolageGrotesque',
                            fontWeight: FontWeight.w800,
                            fontSize: 40,
                            color: KColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer: up next
            Container(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.boardPadding,
                12,
                KSpacing.boardPadding,
                24,
              ),
              child: Row(
                children: [
                  Text(
                    'UP NEXT',
                    style: KTypography.boardMono.copyWith(fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  ...fixtureSongs.skip(1).take(3).map((song) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: KColors.ink600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${song.title} \u00b7 ${song.artist}',
                      style: KTypography.boardMono.copyWith(fontSize: 12),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomColumn extends StatelessWidget {
  final String label;
  final Widget child;

  const _BottomColumn({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: KTypography.boardMono.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class QueuePill {
  final String title;
  final String requester;

  const QueuePill({required this.title, required this.requester});
}
