import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/note_track.dart';
import 'lrc_parser.dart';
import 'mic_service.dart';
import 'performance_scorer.dart';

/// State of the current karaoke playback.
class KaraokeState {
  final Song song;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final int currentLineIndex;
  final String? previousLine;
  final String currentLine;
  final String? nextLine;
  final double lineProgress; // 0.0–1.0 wipe progress within current line
  final double overallProgress; // 0.0–1.0 song progress
  final int score;
  final int pitch;
  final int timing;
  final int combo;
  /// Amplitude consistency (steady vocals) 0–100. Volume is only a proxy —
  /// real beat-timing needs a BPM track, so this rides along as its own stat.
  final int consistency;
  /// Vocal energy 0–100 from the live mic level.
  final int energy;
  /// Pace accuracy 0–100: mic onset rate vs expected syllable rate.
  final int speed;

  const KaraokeState({
    required this.song,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.currentLineIndex = -1,
    this.previousLine,
    this.currentLine = '',
    this.nextLine,
    this.lineProgress = 0.0,
    this.overallProgress = 0.0,
    this.score = 0,
    this.pitch = 0,
    this.timing = 0,
    this.combo = 0,
    this.consistency = 0,
    this.energy = 0,
    this.speed = 0,
  });

  String get positionLabel => _formatDuration(position);
  String get durationLabel => _formatDuration(duration);

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  KaraokeState copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    int? currentLineIndex,
    String? previousLine,
    String? currentLine,
    String? nextLine,
    double? lineProgress,
    double? overallProgress,
    int? score,
    int? pitch,
    int? timing,
    int? combo,
    int? consistency,
    int? energy,
    int? speed,
    bool clearPreviousLine = false,
    bool clearNextLine = false,
  }) {
    return KaraokeState(
      song: song,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      currentLineIndex: currentLineIndex ?? this.currentLineIndex,
      previousLine: clearPreviousLine ? null : (previousLine ?? this.previousLine),
      currentLine: currentLine ?? this.currentLine,
      nextLine: clearNextLine ? null : (nextLine ?? this.nextLine),
      lineProgress: lineProgress ?? this.lineProgress,
      overallProgress: overallProgress ?? this.overallProgress,
      score: score ?? this.score,
      pitch: pitch ?? this.pitch,
      timing: timing ?? this.timing,
      combo: combo ?? this.combo,
      consistency: consistency ?? this.consistency,
      energy: energy ?? this.energy,
      speed: speed ?? this.speed,
    );
  }
}

/// Karaoke playback service combining just_audio with LRC lyric sync.
///
/// Provides a stream of [KaraokeState] that updates every frame with:
/// - Current audio position and playback state
/// - Active lyric line with wipe progress
/// - Simulated score/pitch/timing/combo
///
/// Supports two modes:
/// - **Real audio**: Set a URL with [playUrl] to stream actual backing tracks
/// - **Simulated**: Call [playSimulated] to advance time without audio files
class KaraokePlaybackService {
  final AudioPlayer _player = AudioPlayer();
  Timer? _simTimer;
  Song _song = fixtureSongs.first;
  List<LyricLine> _lyrics = [];

  // Scoring state
  int _simScore = 0;
  int _simPitch = 0;
  int _simTiming = 0;
  int _simCombo = 0;
  int _simLineIndex = -1;
  int _simConsistency = 0;
  int _simEnergy = 0;
  int _simSpeed = 75; // Neutral until the first onset rate lands.

  // Real mic integration
  StreamSubscription<MicData>? _micSubscription;
  final List<double> _recentAmplitudes = [];
  NoteTrack? _noteTrack; // Target melody notes for pitch scoring
  final OnsetDetector _onsetDetector = OnsetDetector();
  int _lastAmplitudeAtMs = 0;

  final _stateController = StreamController<KaraokeState>.broadcast();
  Stream<KaraokeState> get stateStream => _stateController.stream;

  KaraokeState _current = const KaraokeState(song: Song(
    id: '', title: '', artist: '', genre: '', difficulty: '',
    duration: Duration.zero,
  ));
  KaraokeState get currentState => _current;

  // ─── Setup ────────────────────────────────────────────

  /// Load a song and its lyrics. If the song has no lyrics, generate
  /// placeholders from the fixture data.
  void loadSong(Song song) {
    _song = song;
    _lyrics = song.lyrics.isNotEmpty
        ? song.lyrics
        : _generatePlaceholderLyrics(song);
    _noteTrack = song.noteTrack;
    _simScore = 0;
    _simPitch = 0;
    _simTiming = 0;
    _simCombo = 0;
    _simLineIndex = -1;
    _simConsistency = 0;
    _simEnergy = 0;
    _simSpeed = 75;
    _recentAmplitudes.clear();
    _onsetDetector.reset();
    _lastAmplitudeAtMs = 0;
    _current = KaraokeState(song: song, duration: song.duration);
    _stateController.add(_current);
  }

  /// Load lyrics from an LRC string.
  void loadLrc(String lrcContent) {
    _lyrics = LrcParser.parse(lrcContent, totalDuration: _song.duration);
  }

  // ─── Microphone Integration ─────────────────────────

  /// Connect a MicInputService for real-time pitch scoring.
  /// When connected, pitch/timing/combo scores come from real mic data
  /// instead of simulated values.
  void connectMic(MicInputService micService) {
    _micSubscription?.cancel();
    _micSubscription = micService.dataStream.listen(_onMicData);
  }

  /// Disconnect the microphone.
  void disconnectMic() {
    _micSubscription?.cancel();
    _micSubscription = null;

  }

  /// Process real mic data for scoring.
  void _onMicData(MicData data) {
    if (!_current.isPlaying) return;

    // Track recent amplitudes for consistency scoring
    _recentAmplitudes.add(data.amplitude);
    if (_recentAmplitudes.length > 20) {
      _recentAmplitudes.removeAt(0);
    }

    // Speed metric: feed the onset detector so we know how fast the singer
    // is delivering syllables right now.
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (_lastAmplitudeAtMs == 0 || nowMs > _lastAmplitudeAtMs) {
      _onsetDetector.addSample(data.amplitude, nowMs);
      _lastAmplitudeAtMs = nowMs;
    }

    // Score pitch against the target note from the song's melody
    // overallProgress is 0.0–1.0; hzAt expects a 0–100 percentage, so scale
    // FIRST and round AFTER — rounding before scaling collapses the value to
    // 0 or 100, making every mid-song note compare against the first/last note.
    final targetHz = _noteTrack?.hzAt((_current.overallProgress * 100).round()) ?? 440;
    final pitchScore = PitchDetector.scorePitch(data.hz, targetHz);

    // Timing: amplitude consistency is the stand-in until a real BPM track
    // exists (spec item 2 — volume proxy accepted for now).
    final timingScore = PitchDetector.scoreTiming(
      _recentAmplitudes,
      targetAmplitude: 0.5,
    );

    // Consistency and energy as separate normalized stats.
    final consistency = PitchDetector.scoreTiming(
      _recentAmplitudes,
      targetAmplitude: 0.5,
    );
    final energy = PerformanceScorer.energyFromAmplitude(data.amplitude);

    // Speed: mic onset rate vs the current line's expected syllable rate.
    final expectedRate = _expectedSyllablesPerSecond(_current.currentLineIndex);
    final speedScore = PerformanceScorer.scoreSpeed(
      onsetsPerSecond: _onsetDetector.onsetsPerSecond,
      expectedSyllablesPerSecond: expectedRate,
    );

    // Spec-weighted blend (pitch 40 / timing 30 / consistency 15 / energy 15),
    // smoothed with a rolling average so the score is bounded 0–100 instead
    // of accumulating unbounded.
    final sample = PerformanceScorer.blend(
      pitch: pitchScore,
      timing: timingScore,
      consistency: consistency,
      energy: energy,
    );
    _simScore = PerformanceScorer.smooth(_simScore, sample);

    _simPitch = pitchScore;
    _simTiming = timingScore;
    _simConsistency = consistency;
    _simEnergy = energy;
    _simSpeed = speedScore;

    // Emit updated state with real scores
    _current = _current.copyWith(
      score: _simScore,
      pitch: _simPitch,
      timing: _simTiming,
      consistency: _simConsistency,
      energy: _simEnergy,
      speed: _simSpeed,
    );
    _stateController.add(_current);
  }

  /// Expected syllable rate for the current lyric line in syllables/second.
  /// The line's time window is derived from its position percentage and the
  /// next line's; 0 when unknown (instrumental gap / no line active).
  double _expectedSyllablesPerSecond(int lineIndex) {
    if (lineIndex < 0 || lineIndex >= _lyrics.length) return 0;
    final totalSeconds = _song.duration.inMilliseconds / 1000.0;
    if (totalSeconds <= 0) return 0;

    final startPercent = _lyrics[lineIndex].t;
    final endPercent = lineIndex + 1 < _lyrics.length
        ? _lyrics[lineIndex + 1].t
        : 100;
    final lineSeconds = (endPercent - startPercent) / 100.0 * totalSeconds;
    if (lineSeconds <= 0) return 0;

    return _lyrics[lineIndex].syllablesPerSecond(lineSeconds);
  }

  // ─── Real Audio Playback ──────────────────────────────

  /// Play a backing track from a URL (mp3, ogg, etc.).
  Future<void> playUrl(String url) async {
    _simTimer?.cancel();
    try {
      await _player.setUrl(url);
      _current = _current.copyWith(isPlaying: true);
      _stateController.add(_current);

      // Listen to position changes
      _player.positionStream.listen((pos) {
        _updateLyricState(pos);
      });

      // Listen to duration changes
      _player.durationStream.listen((dur) {
        if (dur != null) {
          _current = _current.copyWith(duration: dur);
        }
      });

      // Listen to player state
      _player.playerStateStream.listen((state) {
        final playing = state.playing;
        _current = _current.copyWith(isPlaying: playing);
        _stateController.add(_current);

        if (state.processingState == ProcessingState.completed) {
          _onSongComplete();
        }
      });

      await _player.play();
    } catch (e) {
      // If real audio fails, fall back to simulated
      playSimulated();
    }
  }

  /// Play from a local asset path.
  Future<void> playAsset(String assetPath) async {
    _simTimer?.cancel();
    try {
      await _player.setAsset(assetPath);
      _current = _current.copyWith(isPlaying: true);
      _stateController.add(_current);

      _player.positionStream.listen((pos) {
        _updateLyricState(pos);
      });

      _player.durationStream.listen((dur) {
        if (dur != null) {
          _current = _current.copyWith(duration: dur);
        }
      });

      _player.playerStateStream.listen((state) {
        final playing = state.playing;
        _current = _current.copyWith(isPlaying: playing);
        _stateController.add(_current);

        if (state.processingState == ProcessingState.completed) {
          _onSongComplete();
        }
      });

      await _player.play();
    } catch (e) {
      playSimulated();
    }
  }

  // ─── Simulated Playback (Dev / No Audio Files) ────────

  /// Start simulated playback — advances time at 1x speed without audio.
  void playSimulated() {
    _simTimer?.cancel();
    _current = _current.copyWith(isPlaying: true);
    _stateController.add(_current);

    _simTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final newPos = _current.position + const Duration(milliseconds: 50);
      if (newPos >= _current.duration) {
        _updateLyricState(_current.duration);
        _onSongComplete();
        return;
      }
      _updateLyricState(newPos);
    });
  }

  // ─── Controls ─────────────────────────────────────────

  Future<void> pause() async {
    _simTimer?.cancel();
    try {
      await _player.pause();
    } catch (_) {}
    _current = _current.copyWith(isPlaying: false);
    _stateController.add(_current);
  }

  Future<void> resume() async {
    if (_current.overallProgress >= 1.0) return;
    try {
      await _player.play();
    } catch (_) {
      // If no audio source, restart simulated
      playSimulated();
      return;
    }
    _current = _current.copyWith(isPlaying: true);
    _stateController.add(_current);
  }

  Future<void> seek(Duration position) async {
    _simTimer?.cancel();
    try {
      await _player.seek(position);
    } catch (_) {}
    _updateLyricState(position);
  }

  Future<void> stop() async {
    _simTimer?.cancel();
    disconnectMic();
    try {
      await _player.stop();
    } catch (_) {}
    _current = _current.copyWith(isPlaying: false, position: Duration.zero);
    _stateController.add(_current);
  }

  void reset() {
    _simTimer?.cancel();
    _simScore = 0;
    _simPitch = 0;
    _simTiming = 0;
    _simCombo = 0;
    _simLineIndex = -1;
    _simConsistency = 0;
    _simEnergy = 0;
    _simSpeed = 75;
    _recentAmplitudes.clear();
    _onsetDetector.reset();
    _lastAmplitudeAtMs = 0;
    _current = KaraokeState(
      song: _song,
      duration: _song.duration,
      isPlaying: false,
    );
    _stateController.add(_current);
  }

  // ─── Internals ────────────────────────────────────────

  /// Update the lyric line state based on current audio position.
  void _updateLyricState(Duration position) {
    final totalMs = _current.duration.inMilliseconds;
    if (totalMs <= 0) return;

    final posMs = position.inMilliseconds;
    final overallProgress = (posMs / totalMs).clamp(0.0, 1.0);

    // Find current lyric line by position percentage
    final posPercent = (posMs / totalMs * 100).round();
    int currentIndex = -1;

    for (int i = _lyrics.length - 1; i >= 0; i--) {
      if (posPercent >= _lyrics[i].t) {
        currentIndex = i;
        break;
      }
    }

    // Calculate line progress (wipe within current line)
    double lineProgress = 0.0;
    String? previousLine;
    String currentLine = '';
    String? nextLine;

    if (currentIndex >= 0 && currentIndex < _lyrics.length) {
      final currentStart = _lyrics[currentIndex].t;
      final currentEnd = currentIndex + 1 < _lyrics.length
          ? _lyrics[currentIndex + 1].t
          : 100;

      final lineRange = currentEnd - currentStart;
      if (lineRange > 0) {
        lineProgress = ((posPercent - currentStart) / lineRange).clamp(0.0, 1.0);
      } else {
        lineProgress = 1.0;
      }

      currentLine = _lyrics[currentIndex].text;

      if (currentIndex > 0) {
        previousLine = _lyrics[currentIndex - 1].text;
      }

      if (currentIndex + 1 < _lyrics.length) {
        nextLine = _lyrics[currentIndex + 1].text;
      }
    } else if (_lyrics.isNotEmpty && posPercent < _lyrics.first.t) {
      // Before first lyric
      currentLine = _lyrics.first.text;
      if (_lyrics.length > 1) {
        nextLine = _lyrics[1].text;
      }
    }

    // Update simulated scoring
    if (currentIndex != _simLineIndex && currentIndex >= 0) {
      _simLineIndex = currentIndex;
      _simCombo++;
      // Bounded simulated scores for dev/demo playback: each new line adds a
      // decaying bonus and everything stays within 0–100.
      _simScore = (_simScore + (20 - _simCombo).clamp(2, 18)).clamp(0, 100);
      _simPitch = (75 + (_simCombo * 3).clamp(0, 20)).clamp(75, 98);
      _simTiming = (80 + (_simCombo * 2).clamp(0, 15)).clamp(80, 99);
      _simConsistency = _simTiming;
      _simEnergy = (60 + _simCombo * 2).clamp(60, 95);
      _simSpeed = (70 + (_simCombo * 3).clamp(0, 30)).clamp(70, 100);
    }

    _current = _current.copyWith(
      position: position,
      overallProgress: overallProgress,
      currentLineIndex: currentIndex,
      previousLine: previousLine,
      currentLine: currentLine,
      nextLine: nextLine,
      lineProgress: lineProgress,
      score: _simScore,
      pitch: _simPitch,
      timing: _simTiming,
      combo: _simCombo,
      consistency: _simConsistency,
      energy: _simEnergy,
      speed: _simSpeed,
      clearPreviousLine: previousLine == null,
      clearNextLine: nextLine == null,
    );

    _stateController.add(_current);
  }

  void _onSongComplete() {
    _simTimer?.cancel();
    _current = _current.copyWith(
      isPlaying: false,
      overallProgress: 1.0,
      lineProgress: 1.0,
    );
    _stateController.add(_current);
  }

  /// Generate placeholder lyrics for songs that don't have real lyrics.
  List<LyricLine> _generatePlaceholderLyrics(Song song) {
    final lines = <LyricLine>[];

    // Generate ~8 evenly spaced placeholder lines
    final placeholders = [
      '[Verse 1]',
      'Singing along with the music',
      'Every word feels so alive',
      'The melody takes us higher',
      '[Chorus]',
      'This is our moment to shine',
      'Together we sing tonight',
      'The music never dies',
    ];

    final interval = 100 ~/ (placeholders.length + 1);
    for (int i = 0; i < placeholders.length; i++) {
      lines.add(LyricLine(
        t: (interval * (i + 1)).clamp(5, 95),
        text: placeholders[i],
      ));
    }

    return lines;
  }

  void dispose() {
    _simTimer?.cancel();
    _micSubscription?.cancel();
    _player.dispose();
    _stateController.close();
  }
}
