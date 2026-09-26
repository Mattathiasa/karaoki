/// Shared scoring model for live karaoke co-performance.
///
/// Everything here is normalized to 0–100. The spec weights are:
/// pitch 40% / timing 30% / consistency 15% / energy 15%. The final live
/// score is an exponential moving average over those weighted samples so the
/// displayed number is bounded and smooth instead of accumulating unbounded.
class PerformanceScorer {
  PerformanceScorer._();

  /// Weight of the pitch component in the blended score.
  static const double pitchWeight = 0.4;

  /// Weight of the timing component in the blended score.
  static const double timingWeight = 0.3;

  /// Weight of the (amplitude) consistency component.
  static const double consistencyWeight = 0.15;

  /// Weight of the (vocal) energy component.
  static const double energyWeight = 0.15;

  /// EMA factor for the rolling live score: 15% of each new sample.
  static const double scoreSmoothing = 0.15;

  /// Blend the four components into a single 0–100 sample using the spec
  /// weights. Each input is clamped defensively so a bad metric can never
  /// push the blend out of range.
  static int blend({
    required int pitch,
    required int timing,
    required int consistency,
    required int energy,
  }) {
    final p = pitch.clamp(0, 100).toDouble();
    final t = timing.clamp(0, 100).toDouble();
    final c = consistency.clamp(0, 100).toDouble();
    final e = energy.clamp(0, 100).toDouble();
    return (p * pitchWeight +
            t * timingWeight +
            c * consistencyWeight +
            e * energyWeight)
        .round()
        .clamp(0, 100);
  }

  /// Exponential moving average used to smooth the live score.
  static int smooth(int current, int sample) {
    final next = current * (1 - scoreSmoothing) + sample * scoreSmoothing;
    final rounded = next.round();
    // Integer rounding can trap the EMA one step short of the target
    // (99 * 0.85 + 100 * 0.15 = 99.15 -> 99 forever); nudge across.
    if (rounded == current && sample != current) {
      return (current + (sample > current ? 1 : -1)).clamp(0, 100);
    }
    return rounded.clamp(0, 100);
  }

  /// Vocal energy from the live mic level: amplitude (0.0–1.0) scaled to
  /// 0–100.
  static int energyFromAmplitude(double amplitude) {
    return (amplitude.clamp(0.0, 1.0) * 100).round().clamp(0, 100);
  }

  /// Score how close the singer's onset pacing is to the expected syllable
  /// rate for the current line.
  ///
  /// [onsetsPerSecond] is the singer's measured onset rate (amplitude peaks
  /// per second from the mic). [expectedSyllablesPerSecond] comes from the
  /// lyric line. 100 when within 20% of expected, decaying linearly to 0 at
  /// 2x deviation.
  static int scoreSpeed({
    required double onsetsPerSecond,
    required double expectedSyllablesPerSecond,
  }) {
    final expected = expectedSyllablesPerSecond;
    if (expected <= 0) {
      // Nothing to pace against (e.g. an instrumental gap): stay neutral
      // rather than punishing the singer.
      return 75;
    }
    final actual = onsetsPerSecond;
    if (actual <= 0) return 0; // Not singing at all.
    final deviation = ((actual - expected) / expected).abs();
    if (deviation <= 0.2) return 100;
    // Linear decay from 100 at 20% deviation to 0 at 200% deviation.
    final score = ((2.0 - deviation) / 1.8 * 100).round();
    return score.clamp(0, 100);
  }

  /// Count syllable-like clusters in a lyric line: per word, contiguous
  /// runs of vowels (including 'y', as in "my" or "every"), falling back to
  /// one per word for vowel-less words (acronyms, onomatopoeia).
  static int countSyllables(String text) {
    if (text.trim().isEmpty) return 0;
    final vowelPattern = RegExp(r'[aeiouy]+', caseSensitive: false);
    var count = 0;
    for (final word in text.split(RegExp(r'[^a-zA-Z]+'))) {
      if (word.isEmpty) continue;
      final matches = vowelPattern.allMatches(word).length;
      count += matches > 0 ? matches : 1;
    }
    return count;
  }

  /// Expected syllables per second for a lyric line occupying a share of the
  /// song: [syllables] sung over [lineDurationSeconds].
  static double expectedSyllablesPerSecond({
    required int syllables,
    required double lineDurationSeconds,
  }) {
    if (lineDurationSeconds <= 0 || syllables <= 0) return 0;
    return syllables / lineDurationSeconds;
  }
}

/// Rolling onset detector for the speed metric.
///
/// Feeds mic amplitudes and counts rising-edge peaks per second. A sample is
/// an onset when it rises above [threshold] from below — that corresponds to
/// a new sung syllable landing in the mic.
class OnsetDetector {
  final double threshold;
  final int windowMs;

  final List<int> _onsetTimestampsMs = [];
  bool _wasBelow = true;
  int? _lastTimestampMs;

  OnsetDetector({this.threshold = 0.12, this.windowMs = 6000});

  /// Feed one amplitude sample (0.0–1.0) taken at [timestampMs]. Returns the
  /// current onset rate in peaks per second over the trailing window.
  double addSample(double amplitude, int timestampMs) {
    // A gap in samples (mic hiccup) resets edge tracking so the next sample
    // is not misread as a rising edge.
    final last = _lastTimestampMs;
    if (last != null && timestampMs - last > 500) _wasBelow = true;
    _lastTimestampMs = timestampMs;

    final isAbove = amplitude >= threshold;
    if (isAbove && _wasBelow) {
      _onsetTimestampsMs.add(timestampMs);
    }
    _wasBelow = !isAbove;

    // Drop onsets that fell out of the trailing window.
    final cutoff = timestampMs - windowMs;
    while (_onsetTimestampsMs.isNotEmpty && _onsetTimestampsMs.first < cutoff) {
      _onsetTimestampsMs.removeAt(0);
    }

    final seconds = windowMs / 1000.0;
    return _onsetTimestampsMs.length / seconds;
  }

  /// Most recent onset rate in peaks per second.
  double get onsetsPerSecond {
    if (_onsetTimestampsMs.length < 2) return _onsetTimestampsMs.length.toDouble();
    final spanMs = _onsetTimestampsMs.last - _onsetTimestampsMs.first;
    if (spanMs <= 0) return 0;
    return (_onsetTimestampsMs.length - 1) * 1000.0 / spanMs;
  }

  void reset() {
    _onsetTimestampsMs.clear();
    _wasBelow = true;
    _lastTimestampMs = null;
  }
}
