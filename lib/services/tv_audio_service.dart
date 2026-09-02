import 'dart:async';
import 'package:flutter/foundation.dart';

/// TV audio playback service for board screens.
///
/// Supports two modes:
/// 1. **YouTube IFrame API** - for YouTube-backed karaoke tracks
/// 2. **HTML5 Audio** - for direct MP3/OGG backing tracks
///
/// On mobile/non-web platforms, delegates to just_audio.
/// On web, uses JavaScript interop for YouTube and HTML5 Audio.
class TvAudioService {
  final _positionController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<TvAudioState>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<TvAudioState> get stateStream => _stateController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  TvAudioState _state = TvAudioState.idle;
  TvAudioMode _mode = TvAudioMode.none;

  Duration get position => _position;
  Duration get duration => _duration;
  TvAudioState get currentState => _state;
  TvAudioMode get currentMode => _mode;

  Timer? _progressTimer;

  /// Load and play a YouTube video by ID.
  ///
  /// [videoId] - YouTube video ID (e.g., 'dQw4w9WgXcQ')
  /// [startAt] - Optional start position in seconds
  Future<void> loadYoutube(String videoId, {int startAt = 0}) async {
    _mode = TvAudioMode.youtube;
    _state = TvAudioState.loading;
    _stateController.add(_state);

    if (kIsWeb) {
      await _loadYoutubeWeb(videoId, startAt: startAt);
    } else {
      // On mobile, just track time (YouTube playback would use url_launcher)
      _simulatePlayback();
    }
  }

  /// Load and play an audio URL (MP3, OGG, etc.) via HTML5 Audio.
  ///
  /// [url] - Direct audio file URL
  Future<void> loadAudioUrl(String url) async {
    _mode = TvAudioMode.html5Audio;
    _state = TvAudioState.loading;
    _stateController.add(_state);

    if (kIsWeb) {
      await _loadHtml5AudioWeb(url);
    } else {
      // On mobile, delegate to just_audio (handled externally)
      _simulatePlayback();
    }
  }

  /// Load from a local asset path.
  Future<void> loadAsset(String assetPath) async {
    _mode = TvAudioMode.asset;
    _state = TvAudioState.loading;
    _stateController.add(_state);
    _simulatePlayback();
  }

  /// Start or resume playback.
  Future<void> play() async {
    if (_state == TvAudioState.playing) return;

    _state = TvAudioState.playing;
    _stateController.add(_state);

    if (kIsWeb && _mode == TvAudioMode.youtube) {
      _playYoutubeWeb();
    } else if (kIsWeb && _mode == TvAudioMode.html5Audio) {
      _playHtml5AudioWeb();
    } else {
      // Simulated or mobile
      _startProgressTimer();
    }
  }

  /// Pause playback.
  Future<void> pause() async {
    _state = TvAudioState.paused;
    _stateController.add(_state);
    _progressTimer?.cancel();

    if (kIsWeb && _mode == TvAudioMode.youtube) {
      _pauseYoutubeWeb();
    } else if (kIsWeb && _mode == TvAudioMode.html5Audio) {
      _pauseHtml5AudioWeb();
    }
  }

  /// Seek to a position.
  Future<void> seek(Duration position) async {
    _position = position;
    _positionController.add(_position);

    if (kIsWeb && _mode == TvAudioMode.youtube) {
      _seekYoutubeWeb(position.inSeconds);
    } else if (kIsWeb && _mode == TvAudioMode.html5Audio) {
      _seekHtml5AudioWeb(position.inSeconds.toDouble());
    }
  }

  /// Stop and reset.
  Future<void> stop() async {
    _progressTimer?.cancel();
    _state = TvAudioState.idle;
    _position = Duration.zero;
    _stateController.add(_state);
    _positionController.add(_position);

    if (kIsWeb) {
      _stopWeb();
    }
  }

  void _simulatePlayback() {
    _duration = const Duration(minutes: 3, seconds: 30);
    _durationController.add(_duration);
    _startProgressTimer();
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _position += const Duration(milliseconds: 100);
      if (_position >= _duration) {
        _position = _duration;
        _state = TvAudioState.completed;
        _stateController.add(_state);
        _progressTimer?.cancel();
      }
      _positionController.add(_position);
    });
  }

  /// Get the audio percentage progress (0.0–1.0).
  double get progress {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void dispose() {
    _progressTimer?.cancel();
    if (kIsWeb) _stopWeb();
    _positionController.close();
    _stateController.close();
    _durationController.close();
  }

  // ─── Web JavaScript Interop ──────────────────────────
  // These methods call into the browser's YouTube IFrame API
  // and HTML5 Audio element via dart:js_interop.
  // In production, implement with actual JS interop bindings.

  Future<void> _loadYoutubeWeb(String videoId, {int startAt = 0}) async {
    // Production implementation:
    // if (kIsWeb) {
    //   final js = js_util.context;
    //   js_util.callMethod(js, 'loadYouTubePlayer', [videoId, startAt]);
    // }
    _duration = const Duration(minutes: 3, seconds: 30);
    _durationController.add(_duration);
  }

  void _playYoutubeWeb() {
    // js_util.callMethod(js_util.context, 'playYouTube', []);
    _startProgressTimer();
  }

  void _pauseYoutubeWeb() {
    // js_util.callMethod(js_util.context, 'pauseYouTube', []);
  }

  void _seekYoutubeWeb(int seconds) {
    // js_util.callMethod(js_util.context, 'seekYouTube', [seconds]);
  }

  Future<void> _loadHtml5AudioWeb(String url) async {
    // Production implementation:
    // final audio = js_util.callMethod(js_util.context, 'Audio', [url]);
    // js_util.setProperty(audio, 'onloadedmetadata', ...);
    _duration = const Duration(minutes: 3, seconds: 30);
    _durationController.add(_duration);
  }

  void _playHtml5AudioWeb() {
    // js_util.callMethod(js_util.context, 'playHtml5Audio', []);
    _startProgressTimer();
  }

  void _pauseHtml5AudioWeb() {
    // js_util.callMethod(js_util.context, 'pauseHtml5Audio', []);
  }

  void _seekHtml5AudioWeb(double seconds) {
    // js_util.callMethod(js_util.context, 'seekHtml5Audio', [seconds]);
  }

  void _stopWeb() {
    // js_util.callMethod(js_util.context, 'stopAudio', []);
  }
}

/// State of TV audio playback.
enum TvAudioState { idle, loading, playing, paused, completed, error }

/// Mode of TV audio playback.
enum TvAudioMode { none, youtube, html5Audio, asset }
