import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/services/performance_scorer.dart';

void main() {
  group('PerformanceScorer.blend', () {
    test('uses spec weights: pitch 40 / timing 30 / consistency 15 / energy 15', () {
      expect(
        PerformanceScorer.blend(pitch: 100, timing: 100, consistency: 100, energy: 100),
        100,
      );
      expect(
        PerformanceScorer.blend(pitch: 100, timing: 0, consistency: 0, energy: 0),
        40,
      );
      expect(
        PerformanceScorer.blend(pitch: 0, timing: 100, consistency: 0, energy: 0),
        30,
      );
      expect(
        PerformanceScorer.blend(pitch: 0, timing: 0, consistency: 100, energy: 0),
        15,
      );
      expect(
        PerformanceScorer.blend(pitch: 0, timing: 0, consistency: 0, energy: 100),
        15,
      );
    });

    test('clamps out-of-range inputs', () {
      expect(
        PerformanceScorer.blend(pitch: 500, timing: -50, consistency: 0, energy: 0),
        40,
      );
      expect(
        PerformanceScorer.blend(pitch: 0, timing: 0, consistency: 0, energy: 0),
        0,
      );
    });
  });

  group('PerformanceScorer.smooth', () {
    test('rolling average stays bounded and converges toward samples', () {
      var score = 0;
      for (var i = 0; i < 200; i++) {
        score = PerformanceScorer.smooth(score, 100);
      }
      expect(score, 100);

      var high = 0;
      for (var i = 0; i < 1000; i++) {
        high = PerformanceScorer.smooth(high, 100);
      }
      // Bounded: never exceeds 100 no matter how many samples arrive.
      expect(high, lessThanOrEqualTo(100));
    });

    test('a single sample moves the score by 15% of the gap', () {
      expect(PerformanceScorer.smooth(0, 100), 15);
      expect(PerformanceScorer.smooth(100, 0), 85);
    });
  });

  group('PerformanceScorer.scoreSpeed', () {
    test('100 within 20% of expected pace', () {
      expect(
        PerformanceScorer.scoreSpeed(onsetsPerSecond: 2.0, expectedSyllablesPerSecond: 2.0),
        100,
      );
      expect(
        PerformanceScorer.scoreSpeed(onsetsPerSecond: 2.3, expectedSyllablesPerSecond: 2.0),
        100,
      );
      expect(
        PerformanceScorer.scoreSpeed(onsetsPerSecond: 1.7, expectedSyllablesPerSecond: 2.0),
        100,
      );
    });

    test('decays to 0 as deviation grows', () {
      final mid = PerformanceScorer.scoreSpeed(
        onsetsPerSecond: 2.0 * 1.6,
        expectedSyllablesPerSecond: 2.0,
      );
      expect(mid, inExclusiveRange(1, 99));

      expect(
        PerformanceScorer.scoreSpeed(onsetsPerSecond: 0.0, expectedSyllablesPerSecond: 2.0),
        0,
      );
      expect(
        PerformanceScorer.scoreSpeed(onsetsPerSecond: 6.0, expectedSyllablesPerSecond: 2.0),
        0,
      );
    });

    test('neutral 75 when there is nothing to pace against', () {
      expect(
        PerformanceScorer.scoreSpeed(onsetsPerSecond: 3.0, expectedSyllablesPerSecond: 0),
        75,
      );
    });
  });

  group('PerformanceScorer.countSyllables', () {
    test('counts vowel clusters per word', () {
      expect(PerformanceScorer.countSyllables('hello'), 2);
      expect(PerformanceScorer.countSyllables('neon midnight'), 3);
      // 'y' counts as a vowel: e-v-e-r-y -> e, e, y.
      expect(PerformanceScorer.countSyllables('every'), 3);
      expect(PerformanceScorer.countSyllables(''), 0);
    });

    test('vowel-less words count once', () {
      expect(PerformanceScorer.countSyllables('shh brm'), 2);
    });
  });

  group('PerformanceScorer.energyFromAmplitude', () {
    test('maps amplitude onto 0-100', () {
      expect(PerformanceScorer.energyFromAmplitude(0.0), 0);
      expect(PerformanceScorer.energyFromAmplitude(0.5), 50);
      expect(PerformanceScorer.energyFromAmplitude(1.0), 100);
    });
  });

  group('OnsetDetector', () {
    test('counts rising-edge peaks per second over the trailing window', () {
      final detector = OnsetDetector(windowMs: 1000);
      var t = 0;
      // 2 Hz square-ish envelope: on 100ms, off 400ms.
      for (var i = 0; i < 100; i++) {
        final above = (t % 500) < 100;
        detector.addSample(above ? 0.5 : 0.01, t);
        t += 10;
      }
      // 2 onsets per 1000ms window.
      expect(detector.onsetsPerSecond, closeTo(2.0, 0.3));
    });

    test('quiet signal produces zero onsets', () {
      final detector = OnsetDetector();
      for (var i = 0; i < 50; i++) {
        detector.addSample(0.01, i * 80);
      }
      expect(detector.onsetsPerSecond, 0);
    });

    test('reset clears history', () {
      final detector = OnsetDetector();
      detector.addSample(0.6, 0);
      detector.addSample(0.01, 80);
      detector.addSample(0.6, 160);
      detector.reset();
      expect(detector.onsetsPerSecond, 0);
    });
  });
}
