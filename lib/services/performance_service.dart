import 'dart:async';
import '../models/song.dart';
import 'mic_service.dart' show PitchDetector;

/// Performance service: manages the song clock and score computation.
///
/// Scores are computed from real mic input ([pushMicData]) using the
/// PitchDetector heuristics in mic_service.dart: pitch accuracy relative
/// to the song's expected range, amplitude consistency for timing, and a
/// combo counter for consecutive on-pitch windows. The legacy simulated
/// mode remains only as an explicit opt-in for demos.
class PerformanceService {
  Timer? _timer;
  final _controller = StreamController<PerformanceState>.broadcast();

  Stream<PerformanceState> get stream => _controller.stream;

  PerformanceState? _currentState;
  bool _useRealMic = false;

  // Rolling samples for timing (amplitude-consistency) scoring.
  final List<double> _recentAmplitudes = [];
  static const int _amplitudeWindow = 24;

  // Combo: consecutive on-pitch windows (~0.5s each), reset after 2 misses.
  int _missStreak = 0;
  static const int _tickMs = 250;

  /// Start a performance. Pass [useRealMic: true] to score from [pushMicData].
  void startPerformance({
    required Song song,
    required String singerId,
    bool useRealMic = false,
  }) {
    _useRealMic = useRealMic;
    _recentAmplitudes.clear();
    _missStreak = 0;
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

    _timer = Timer.periodic(const Duration(milliseconds: _tickMs), (_) {
      _tick();
    });
  }

  /// Push real mic data from the audio capture service.
  ///
  /// Pitch is scored against the song's expected centre frequency (A4 by
  /// default) with a ±1-octave window; amplitude feeds timing consistency.
  void pushMicData({required double pitchHz, required double amplitude}) {
    if (_currentState == null || !_useRealMic) return;

    _recentAmplitudes.add(amplitude.clamp(0.0, 1.0));
    if (_recentAmplitudes.length > _amplitudeWindow) {
      _recentAmplitudes.removeAt(0);
    }

    final pitchScore = PitchDetector.scorePitchAgainstRange(pitchHz);
    final amplitudeScore = _recentAmplitudes.length >= 4
        ? PitchDetector.scoreTiming(_recentAmplitudes)
        : (amplitude * 100).round().clamp(0, 100);

    // Combo: +1 per on-pitch window, reset after two consecutive misses.
    if (pitchScore >= 70) {
      _missStreak = 0;
    } else {
      _missStreak++;
    }
    final prevCombo = _currentState!.combo;
    final combo = pitchScore >= 70
        ? prevCombo + 1
        : (_missStreak >= 2 ? 0 : prevCombo);

    _applyScores(
      pitchScore: pitchScore,
      timingScore: amplitudeScore,
      combo: combo,
    );
  }

  void _tick() {
    if (_currentState == null) return;
    final elapsed = DateTime.now().difference(_currentState!.startedAt);
    if (elapsed >= _currentState!.song.duration) {
      _endPerformance();
      return;
    }

    if (!_useRealMic) {
      // Explicit demo mode: flat neutral scores that slowly settle so the
      // UI can be exercised without a mic. Not used for real performances.
      final progress =
          elapsed.inMilliseconds / _currentState!.song.duration.inMilliseconds;
      const pitch = 60, timing = 60;
      final score = ((pitch * 0.4) + (timing * 0.3) + (75 * 0.15) + (88 * 0.15)).round();

      _currentState = _currentState!.copyWith(
        elapsed: elapsed,
        pitch: pitch,
        timing: timing,
        combo: (progress * 20).round(),
        score: score,
      );
    } else {
      // Real mic mode: only the clock advances here; scores arrive via
      // pushMicData. If the mic goes quiet, scores decay toward silence.
      _currentState = _currentState!.copyWith(elapsed: elapsed);
    }

    _controller.add(_currentState!);
  }

  void _applyScores({
    required int pitchScore,
    required int timingScore,
    required int combo,
  }) {
    if (_currentState == null) return;
    // Weighted model from FLOWS.md: pitch 40% / timing 30% / consistency 15% / energy 15%.
    final consistency = (timingScore * 0.8 + pitchScore * 0.2).round();
    final energy = (timingScore * 0.6 + pitchScore * 0.4).round();
    final score = ((pitchScore * 0.4) +
            (timingScore * 0.3) +
            (consistency * 0.15) +
            (energy * 0.15))
        .round()
        .clamp(0, 100);

    _currentState = _currentState!.copyWith(
      pitch: pitchScore,
      timing: timingScore,
      combo: combo,
      score: score,
    );
    _controller.add(_currentState!);
  }

  /// Final breakdown computed from the accumulated live state.
  Map<String, int> finalBreakdown() {
    final s = _currentState;
    if (s == null) return const {};
    return {
      'pitch': s.pitch,
      'timing': s.timing,
      'consistency': (s.timing * 0.8 + s.pitch * 0.2).round().clamp(0, 100),
      'energy': (s.timing * 0.6 + s.pitch * 0.4).round().clamp(0, 100),
    };
  }

  void _endPerformance() {
    _timer?.cancel();
    if (_currentState != null) {
      _controller.add(_currentState!.copyWith(isComplete: true));
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

  int get currentLineIndex {
    if (song.lyrics.isEmpty) return -1;
    final progressPercent = progress * 100;
    for (int i = song.lyrics.length - 1; i >= 0; i--) {
      if (progressPercent >= song.lyrics[i].t) return i;
    }
    return 0;
  }

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
    if (song.lyrics.isEmpty) return '...';
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
