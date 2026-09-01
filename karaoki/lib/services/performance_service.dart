import 'dart:async';
import 'dart:math';
import '../models/song.dart';

/// Performance service — manages the song clock and score computation
class PerformanceService {
  Timer? _timer;
  final _controller = StreamController<PerformanceState>.broadcast();

  Stream<PerformanceState> get stream => _controller.stream;

  PerformanceState? _currentState;

  void startPerformance({
    required Song song,
    required String singerId,
  }) {
    _currentState = PerformanceState(
      song: song,
      singerId: singerId,
      startedAt: DateTime.now(),
      elapsed: Duration.zero,
      pitch: 0,
      timing: 0,
      combo: 0,
      score: 0,
    );

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_currentState == null) return;
      final elapsed = DateTime.now().difference(_currentState!.startedAt);
      if (elapsed >= song.duration) {
        _endPerformance();
        return;
      }

      // Simulate pitch and timing data
      final progress = elapsed.inMilliseconds / song.duration.inMilliseconds;
      final pitch = (85 + 15 * sin(progress * 6.28)).round();
      final timing = (80 + 20 * cos(progress * 4.2)).round();
      final combo = progress > 0.1 ? (progress * 20).round() : 0;
      final score = ((pitch * 0.4) + (timing * 0.3) + (75 * 0.15) + (88 * 0.15)).round();

      _currentState = _currentState!.copyWith(
        elapsed: elapsed,
        pitch: pitch,
        timing: timing,
        combo: combo,
        score: score,
      );

      _controller.add(_currentState!);
    });
  }

  void _endPerformance() {
    _timer?.cancel();
    if (_currentState != null) {
      _controller.add(_currentState!.copyWith(
        isComplete: true,
      ));
    }
  }

  void stop() {
    _timer?.cancel();
    _currentState = null;
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

class PerformanceState {
  final Song song;
  final String singerId;
  final DateTime startedAt;
  final Duration elapsed;
  final int pitch;
  final int timing;
  final int combo;
  final int score;
  final bool isComplete;

  const PerformanceState({
    required this.song,
    required this.singerId,
    required this.startedAt,
    required this.elapsed,
    this.pitch = 0,
    this.timing = 0,
    this.combo = 0,
    this.score = 0,
    this.isComplete = false,
  });

  double get progress => song.duration.inMilliseconds > 0
      ? elapsed.inMilliseconds / song.duration.inMilliseconds
      : 0.0;

  Duration get remaining => song.duration - elapsed;

  /// Current lyric line index based on progress
  int get currentLineIndex {
    if (song.lyrics.isEmpty) return -1;
    final progressPercent = progress * 100;
    for (int i = song.lyrics.length - 1; i >= 0; i--) {
      if (progressPercent >= song.lyrics[i].t) return i;
    }
    return 0;
  }

  /// Progress within the current lyric line (0.0 to 1.0)
  double get lineProgress {
    if (song.lyrics.isEmpty || currentLineIndex < 0) return 0.0;
    final current = song.lyrics[currentLineIndex];
    final nextIndex = currentLineIndex + 1;
    if (nextIndex >= song.lyrics.length) return 1.0;

    final next = song.lyrics[nextIndex];
    final progressPercent = progress * 100;
    final lineDuration = next.t - current.t;
    if (lineDuration <= 0) return 1.0;
    return ((progressPercent - current.t) / lineDuration).clamp(0.0, 1.0);
  }

  String? get previousLine {
    if (song.lyrics.isEmpty || currentLineIndex <= 0) return null;
    return song.lyrics[currentLineIndex - 1].text;
  }

  String get currentLine {
    if (song.lyrics.isEmpty) return '♪ ♪ ♪';
    return song.lyrics[currentLineIndex].text;
  }

  String? get nextLine {
    if (song.lyrics.isEmpty || currentLineIndex >= song.lyrics.length - 1) return null;
    return song.lyrics[currentLineIndex + 1].text;
  }

  String get elapsedLabel {
    final mins = elapsed.inMinutes;
    final secs = elapsed.inSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String get durationLabel {
    final mins = song.duration.inMinutes;
    final secs = song.duration.inSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  PerformanceState copyWith({
    Duration? elapsed,
    int? pitch,
    int? timing,
    int? combo,
    int? score,
    bool? isComplete,
  }) {
    return PerformanceState(
      song: song,
      singerId: singerId,
      startedAt: startedAt,
      elapsed: elapsed ?? this.elapsed,
      pitch: pitch ?? this.pitch,
      timing: timing ?? this.timing,
      combo: combo ?? this.combo,
      score: score ?? this.score,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
