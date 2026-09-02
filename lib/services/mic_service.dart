import 'dart:async';
import 'dart:math';

/// Microphone capture and pitch detection service
/// Provides real-time pitch (Hz) and amplitude data from the device mic
class MicService {
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  final _pitchController = StreamController<MicData>.broadcast();
  Stream<MicData> get pitchStream => _pitchController.stream;

  Timer? _simTimer;
  final _rng = Random();

  /// Start capturing microphone input
  /// In production, this uses audio_waveforms package to capture raw audio
  /// and a pitch detection algorithm (e.g., autocorrelation) to extract Hz
  Future<bool> startCapture() async {
    // TODO: In production, use audio_waveforms:
    //   final recorder = RecorderController();
    //   await recorder.record();
    //   recorder.onRecorderConfigs.listen((config) { ... });
    //   recorder.onCurrentDuration.listen((duration) {
    //     // Process audio buffer with pitch detection
    //     final hz = detectPitch(audioBuffer);
    //     _pitchController.add(MicData(hz: hz, amplitude: amplitude));
    //   });

    _isRecording = true;

    // Simulate mic data for development
    _simTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_isRecording) return;
      // Simulate a singer hitting notes around 440Hz (A4) with natural variation
      final baseHz = 440.0 + 30 * sin(_rng.nextDouble() * 6.28);
      final hz = baseHz + _rng.nextDouble() * 20 - 10;
      final amplitude = 0.3 + _rng.nextDouble() * 0.5;
      _pitchController.add(MicData(hz: hz, amplitude: amplitude));
    });

    return true;
  }

  /// Stop capturing
  Future<void> stopCapture() async {
    _isRecording = false;
    _simTimer?.cancel();
  }

  void dispose() {
    _simTimer?.cancel();
    _pitchController.close();
  }
}

/// Data point from microphone capture
class MicData {
  final double hz; // Fundamental frequency in Hz
  final double amplitude; // 0.0 to 1.0

  const MicData({required this.hz, required this.amplitude});
}

/// Pitch detection utilities
class PitchDetector {
  /// Convert frequency (Hz) to musical note name
  static String hzToNote(double hz) {
    if (hz <= 0) return '--';
    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final noteNum = 12 * (log(hz / 440) / log(2));
    final note = (noteNum.round() + 69) % 12;
    final octave = ((noteNum.round() + 69) / 12).floor();
    return '${noteNames[note]}$octave';
  }

  /// Score pitch accuracy against a target Hz
  /// Returns 0-100 where 100 is perfect match
  static int scorePitch(double actualHz, double targetHz) {
    if (targetHz <= 0 || actualHz <= 0) return 0;
    final diff = (actualHz - targetHz).abs();
    // Within 10Hz = 100, within 50Hz = 80, within 100Hz = 50
    if (diff < 10) return 100;
    if (diff < 50) return (100 - (diff - 10) * 0.5).round();
    if (diff < 100) return (80 - (diff - 50) * 0.6).round();
    return (50 - (diff - 100) * 0.3).round().clamp(0, 50);
  }
}
