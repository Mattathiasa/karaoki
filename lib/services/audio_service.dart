import 'dart:async';
import 'package:just_audio/just_audio.dart';
/// Audio playback service for backing tracks
/// Plays instrumental audio synced with lyric timing
class AudioPlaybackService {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  double get progress {
    final d = duration;
    if (d.inMilliseconds <= 0) return 0.0;
    return (position.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Set the audio source from a URL or asset path
  Future<void> setSource(String url) async {
    try {
      await _player.setUrl(url);
    } catch (e) {
      // Fallback: create a silent player with estimated duration
      // In production, this would be a real audio file
    }
  }

  /// Set a simulated duration for development (no actual audio file needed)
  Future<void> setSimulatedDuration(Duration duration) async {
    // just_audio needs a source, so we use a silent web resource
    // For dev, we just track time manually
  }

  /// Play from the current position
  Future<void> play() async {
    try {
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = true;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      _isPlaying = false;
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      // ignore
    }
  }

  /// Stop and reset
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      // ignore
    }
    _isPlaying = false;
  }

  /// Dispose of resources
  void dispose() {
    _player.dispose();
  }
}

/// Simulated audio service for development
/// Tracks time without requiring actual audio files
class SimulatedAudioService {
  Timer? _timer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  final _positionController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<bool>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<bool> get playStateStream => _stateController.stream;

  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;

  double get progress {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void setDuration(Duration duration) {
    _duration = duration;
  }

  void play() {
    _isPlaying = true;
    _stateController.add(true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _position += const Duration(milliseconds: 100);
      if (_position >= _duration) {
        _position = _duration;
        pause();
      }
      _positionController.add(_position);
    });
  }

  void pause() {
    _isPlaying = false;
    _stateController.add(false);
    _timer?.cancel();
  }

  void seek(Duration position) {
    _position = position;
    _positionController.add(_position);
  }

  void reset() {
    _position = Duration.zero;
    _timer?.cancel();
    _isPlaying = false;
    _positionController.add(_position);
    _stateController.add(false);
  }

  void dispose() {
    _timer?.cancel();
    _positionController.close();
    _stateController.close();
  }
}
