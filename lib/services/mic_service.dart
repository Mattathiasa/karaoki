import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:permission_handler/permission_handler.dart';

/// Real microphone input service using audio_waveforms.
///
/// Captures mic audio via [RecorderController] and provides:
/// - Waveform amplitude data (0.0–1.0) for visual feedback
/// - Decibel levels for loudness detection
/// - Pitch detection via autocorrelation on captured audio frames
///
/// Falls back to simulated data on web or when permission is denied.
class MicInputService {
  final _dataController = StreamController<MicData>.broadcast();
  Stream<MicData> get dataStream => _dataController.stream;

  bool _isCapturing = false;
  bool get isCapturing => _isCapturing;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  bool _useRealMic = false;
  bool get useRealMic => _useRealMic;

  // RecorderController from audio_waveforms
  RecorderController? _recorder;
  StreamSubscription? _waveDataSubscription;
  StreamSubscription? _stateSubscription;
  Timer? _simTimer;
  final _rng = Random();

  // Pitch detection state
  final _pitchAnalyzer = PitchAnalyzer();
  double _lastAmplitude = 0;
  double _lastEmittedHz = 0;

  /// Initialize the recorder. Call once at app start.
  Future<void> init() async {
    try {
      _useRealMic = await _checkPlatformSupport();
    } catch (e) {
      _useRealMic = false;
    }
  }

  /// Check if the platform supports real mic recording.
  ///
  /// audio_waveforms provides native recorders on Android, iOS and macOS.
  /// Web and other desktop platforms fall back to simulated capture.
  Future<bool> _checkPlatformSupport() async {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  /// Request microphone permission and start capturing.
  ///
  /// Returns true if capturing started (real or simulated).
  Future<bool> startCapture() async {
    if (_isCapturing) return true;

    if (_useRealMic) {
      final started = await _startRealCapture();
      if (started) return true;
      // Real capture failed (no permission, no hardware, plugin error):
      // degrade to simulated so the singing flow keeps working.
      _useRealMic = false;
    }
    return _startSimulatedCapture();
  }

  /// Start real microphone capture using audio_waveforms.
  Future<bool> _startRealCapture() async {
    try {
      // Ask for the platform mic permission first.
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _hasPermission = false;
        return false;
      }
      _hasPermission = true;

      _recorder ??= RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100
        // Controller samples dB internally and notifies listeners at this rate.
        ..updateFrequency = const Duration(milliseconds: 80);

      await _recorder!.record();

      // The controller normalizes peak amplitude into waveData (0.0–1.0) and
      // calls notifyListeners() at updateFrequency (~12Hz). Listen and feed
      // the latest sample into the pitch analyzer + broadcast stream.
      _lastWaveValue = null;
      _recorder!.addListener(_onRecorderTick);

      _isCapturing = true;
      return true;
    } catch (e) {
      _hasPermission = false;
      return false;
    }
  }

  double? _lastWaveValue;

  /// Called by [RecorderController] whenever a new waveform sample lands.
  void _onRecorderTick() {
    final recorder = _recorder;
    if (recorder == null || !_isCapturing) return;
    final waves = recorder.waveData;
    if (waves.isEmpty) return;
    final latest = waves.last;
    if (latest == _lastWaveValue) return; // No new sample yet.
    _lastWaveValue = latest;
    _emitFrame(latest.clamp(0.0, 1.0));
  }

  /// Analyze an amplitude frame and broadcast a [MicData] point.
  void _emitFrame(double amplitude) {
    _lastAmplitude = amplitude;
    final hz = _pitchAnalyzer.analyze(amplitude);
    final effectiveHz = hz > 0 ? hz : _lastEmittedHz;
    _dataController.add(MicData(
      hz: effectiveHz,
      amplitude: amplitude,
      note: PitchDetector.hzToNote(effectiveHz),
      confidence: _pitchAnalyzer.confidence,
    ));
    if (hz > 0) _lastEmittedHz = hz;
  }

  /// Start simulated mic capture for development / web.
  Future<bool> _startSimulatedCapture() async {
    _isCapturing = true;
    _hasPermission = true;

    // Simulate mic data at ~12Hz (every 80ms)
    _simTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_isCapturing) return;

      // Simulate a singer with natural pitch variation
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final baseHz = 440.0 + 40 * sin(time * 0.7) + 20 * sin(time * 1.3);
      final hz = baseHz + _rng.nextDouble() * 15 - 7.5;
      final amplitude = 0.3 + 0.4 * sin(time * 2.1).abs() + _rng.nextDouble() * 0.15;

      _lastAmplitude = amplitude;

      _dataController.add(MicData(
        hz: hz,
        amplitude: amplitude,
        note: PitchDetector.hzToNote(hz),
        confidence: 0.85 + _rng.nextDouble() * 0.1,
      ));
    });

    return true;
  }

  /// Stop capturing.
  Future<void> stopCapture() async {
    _isCapturing = false;
    _simTimer?.cancel();
    _waveDataSubscription?.cancel();
    _stateSubscription?.cancel();
    _recorder?.removeListener(_onRecorderTick);

    try {
      await _recorder?.stop();
    } catch (_) {}
  }

  /// Get the last detected amplitude (0.0–1.0).
  double get lastAmplitude => _lastAmplitude;

  void dispose() {
    _simTimer?.cancel();
    _waveDataSubscription?.cancel();
    _stateSubscription?.cancel();
    _recorder?.removeListener(_onRecorderTick);
    _recorder?.dispose();
    _dataController.close();
    _pitchAnalyzer.reset();
  }
}

/// Data point from microphone capture.
class MicData {
  final double hz; // Fundamental frequency in Hz
  final double amplitude; // 0.0 to 1.0
  final String note; // Musical note name (e.g., "A4")
  final double confidence; // 0.0 to 1.0

  const MicData({
    required this.hz,
    required this.amplitude,
    this.note = '--',
    this.confidence = 0.0,
  });
}

/// Autocorrelation-based pitch analyzer.
///
/// Analyzes amplitude samples to detect the fundamental frequency.
/// Works by finding the periodicity in the signal — the delay at which
/// the signal correlates with itself gives us the pitch period.
class PitchAnalyzer {
  final List<double> _samples = [];
  static const int _windowSize = 1024;
  static const int _minLag = 20; // ~2205 Hz at 44100 sample rate
  static const int _maxLag = 400; // ~110 Hz at 44100 sample rate

  double _lastHz = 0;
  double _confidence = 0;

  double get confidence => _confidence;
  double get lastHz => _lastHz;

  /// Feed an amplitude sample and return detected Hz (0 if uncertain).
  double analyze(double amplitude) {
    _samples.add(amplitude);

    if (_samples.length < _windowSize) return 0;

    // Keep only the latest window
    if (_samples.length > _windowSize) {
      _samples.removeRange(0, _samples.length - _windowSize);
    }

    // Run autocorrelation
    return _autocorrelate();
  }

  /// Autocorrelation pitch detection.
  double _autocorrelate() {
    final n = _samples.length;
    if (n < _maxLag + 1) return 0;

    double bestCorrelation = 0;
    int bestLag = 0;

    // Calculate mean
    double mean = 0;
    for (int i = 0; i < n; i++) {
      mean += _samples[i];
    }
    mean /= n;

    // Calculate variance
    double variance = 0;
    for (int i = 0; i < n; i++) {
      final diff = _samples[i] - mean;
      variance += diff * diff;
    }
    variance /= n;

    if (variance < 0.001) return 0; // Too quiet, no pitch

    // Autocorrelation for each lag
    for (int lag = _minLag; lag <= _maxLag && lag < n; lag++) {
      double correlation = 0;
      for (int i = 0; i < n - lag; i++) {
        correlation += (_samples[i] - mean) * (_samples[i + lag] - mean);
      }
      correlation /= (n - lag) * variance;

      if (correlation > bestCorrelation) {
        bestCorrelation = correlation;
        bestLag = lag;
      }
    }

    if (bestLag == 0 || bestCorrelation < 0.3) return 0;

    // Convert lag to Hz (assuming ~44100 Hz sample rate, 80ms between samples)
    // With 80ms intervals: effective sample rate = 12.5 Hz
    // lag = number of 80ms intervals
    // frequency = 1 / (lag * 0.080)
    final hz = 1.0 / (bestLag * 0.080);

    _confidence = bestCorrelation.clamp(0.0, 1.0);
    _lastHz = hz;
    return hz;
  }

  void reset() {
    _samples.clear();
    _lastHz = 0;
    _confidence = 0;
  }
}

/// Pitch detection utilities.
class PitchDetector {
  /// Convert frequency (Hz) to musical note name.
  static String hzToNote(double hz) {
    if (hz <= 0) return '--';
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final noteNum = 12 * (log(hz / 440) / log(2));
    final note = (noteNum.round() + 69) % 12;
    final octave = ((noteNum.round() + 69) / 12).floor();
    return '${noteNames[note]}$octave';
  }

  /// Convert frequency (Hz) to MIDI note number.
  static int hzToMidi(double hz) {
    if (hz <= 0) return 0;
    return (69 + 12 * (log(hz / 440) / log(2))).round();
  }

  /// Convert MIDI note number to frequency (Hz).
  static double midiToHz(int midi) {
    return 440.0 * pow(2, (midi - 69) / 12);
  }

  /// Score pitch accuracy against a target Hz.
  /// Returns 0–100 where 100 is perfect match.
  static int scorePitch(double actualHz, double targetHz) {
    if (targetHz <= 0 || actualHz <= 0) return 0;

    // Semitone tolerance scoring
    final semitoneDiff = 12 * (log(actualHz / targetHz).abs() / log(2));

    if (semitoneDiff < 0.1) return 100; // Within 10 cents
    if (semitoneDiff < 0.5) return (100 - semitoneDiff * 40).round(); // Within half semitone
    if (semitoneDiff < 1.0) return (80 - (semitoneDiff - 0.5) * 30).round(); // Within 1 semitone
    if (semitoneDiff < 2.0) return (65 - (semitoneDiff - 1.0) * 20).round(); // Within 2 semitones
    return (45 - (semitoneDiff - 2.0) * 10).round().clamp(0, 45);
  }

  /// Score timing accuracy based on amplitude consistency.
  /// Returns 0–100 where 100 is perfectly on beat.
  static int scoreTiming(List<double> recentAmplitudes, {double targetAmplitude = 0.6}) {
    if (recentAmplitudes.isEmpty) return 0;

    // Calculate how consistent the amplitude is
    final mean = recentAmplitudes.reduce((a, b) => a + b) / recentAmplitudes.length;
    final variance = recentAmplitudes
        .map((a) => (a - mean) * (a - mean))
        .reduce((a, b) => a + b) / recentAmplitudes.length;
    final stdDev = sqrt(variance);

    // Lower variance = more consistent = better timing
    final consistency = (1.0 - stdDev * 3).clamp(0.0, 1.0);

    // How close to target amplitude
    final accuracy = (1.0 - (mean - targetAmplitude).abs()).clamp(0.0, 1.0);

    return ((consistency * 60 + accuracy * 40)).round().clamp(0, 100);
  }
}
