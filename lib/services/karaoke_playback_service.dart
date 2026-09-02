import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import 'lrc_parser.dart';
import 'mic_service.dart';

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

  // Real mic integration
  StreamSubscription<MicData>? _micSubscription;
  final List<double> _recentAmplitudes = [];
  final double _currentTargetHz = 440; // Current target note for pitch scoring

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
    _simScore = 0;
    _simPitch = 0;
    _simTiming = 0;
    _simCombo = 0;
    _simLineIndex = -1;
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

    // Track recent amplitudes for timing scoring
    _recentAmplitudes.add(data.amplitude);
    if (_recentAmplitudes.length > 20) {
      _recentAmplitudes.removeAt(0);
    }

    // Score pitch against the current target note
    // (In production, target notes would come from the song's note track)
    final pitchScore = PitchDetector.scorePitch(data.hz, _currentTargetHz);

    // Score timing based on amplitude consistency
    final timingScore = PitchDetector.scoreTiming(
      _recentAmplitudes,
      targetAmplitude: 0.5,
    );

    // Update combo on line changes (handled in _updateLyricState)
    // But accumulate score from real mic
    if (pitchScore > 60) {
      _simScore += (pitchScore * 0.5).round();
    }

    _simPitch = pitchScore;
    _simTiming = timingScore;

    // Emit updated state with real scores
    _current = _current.copyWith(
      score: _simScore,
      pitch: _simPitch,
      timing: _simTiming,
    );
    _stateController.add(_current);
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
      _simScore += 100 * _simCombo;
      _simPitch = (75 + (_simCombo * 3).clamp(0, 20)).clamp(75, 98);
      _simTiming = (80 + (_simCombo * 2).clamp(0, 15)).clamp(80, 99);
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
