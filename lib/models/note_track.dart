import 'dart:math';

/// A target melody note at a specific time in the song.
class TargetNote {
  /// Timestamp as percentage of song duration (0–100).
  final int t;

  /// Target frequency in Hz.
  final double hz;

  /// Duration of this note as percentage of song duration.
  final int durationPercent;

  /// Musical note name (auto-computed from Hz).
  String get noteName => _hzToNote(hz);

  const TargetNote({
    required this.t,
    required this.hz,
    this.durationPercent = 5,
  });

  /// Convert Hz to note name.
  static String _hzToNote(double hz) {
    if (hz <= 0) return '--';
    const names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final num = 12 * (log(hz / 440) / log(2));
    final note = (num.round() + 69) % 12;
    final octave = ((num.round() + 69) / 12).floor();
    return '${names[note]}$octave';
  }

  Map<String, dynamic> toJson() => {
    't': t,
    'hz': hz,
    'd': durationPercent,
  };

  factory TargetNote.fromJson(Map<String, dynamic> json) => TargetNote(
    t: json['t'] as int,
    hz: (json['hz'] as num).toDouble(),
    durationPercent: json['d'] as int? ?? 5,
  );
}

/// A complete melody track for a song, containing target notes
/// that the singer's pitch should match against.
class NoteTrack {
  final String songId;
  final List<TargetNote> notes;

  const NoteTrack({
    required this.songId,
    this.notes = const [],
  });

  /// Find the target note active at a given percentage position.
  /// Returns null if no note is active at that position.
  TargetNote? noteAt(int positionPercent) {
    for (int i = notes.length - 1; i >= 0; i--) {
      final note = notes[i];
      if (positionPercent >= note.t &&
          positionPercent < note.t + note.durationPercent) {
        return note;
      }
    }
    return null;
  }

  /// Get the target Hz at a given position, or a default if no note.
  double hzAt(int positionPercent, {double defaultHz = 440}) {
    final note = noteAt(positionPercent);
    return note?.hz ?? defaultHz;
  }

  /// Interpolate between notes for smooth pitch guide.
  double interpolateHz(int positionPercent) {
    if (notes.isEmpty) return 440;

    // Find surrounding notes
    TargetNote? before;
    TargetNote? after;

    for (int i = 0; i < notes.length; i++) {
      if (notes[i].t <= positionPercent) {
        before = notes[i];
      }
      if (notes[i].t > positionPercent && after == null) {
        after = notes[i];
        break;
      }
    }

    if (before == null && after == null) return 440;
    if (before == null) return after!.hz;
    if (after == null) return before.hz;

    // Linear interpolation between notes
    final range = after.t - before.t;
    if (range <= 0) return before.hz;
    final progress = (positionPercent - before.t) / range;
    return before.hz + (after.hz - before.hz) * progress;
  }

  /// Generate a demo note track from common chord progressions.
  /// Used for fixture songs that don't have real melody data.
  static NoteTrack generateDemo(String songId, Duration duration, {String key = 'C'}) {
    final notes = <TargetNote>[];

    // Common pop melody note patterns (in Hz)
    // Based on C major scale: C4=262, D4=294, E4=330, F4=349, G4=392, A4=440, B4=494
    const scaleHz = [262, 294, 330, 349, 392, 440, 494, 523]; // C4 to C5

    final rng = Random(songId.hashCode);
    final totalMs = duration.inMilliseconds;
    final noteCount = (totalMs / 2000).round(); // One note every ~2 seconds

    int pos = 5; // Start at 5%
    for (int i = 0; i < noteCount && pos < 95; i++) {
      // Pick a note from the scale with some variation
      final scaleIdx = rng.nextInt(scaleHz.length);
      final hz = scaleHz[scaleIdx].toDouble() + rng.nextDouble() * 20 - 10;
      final dur = 3 + rng.nextInt(5); // 3–7% duration

      notes.add(TargetNote(t: pos, hz: hz, durationPercent: dur));
      pos += dur + rng.nextInt(3);
    }

    return NoteTrack(songId: songId, notes: notes);
  }

  Map<String, dynamic> toJson() => {
    'songId': songId,
    'notes': notes.map((n) => n.toJson()).toList(),
  };

  factory NoteTrack.fromJson(Map<String, dynamic> json) => NoteTrack(
    songId: json['songId'] as String,
    notes: (json['notes'] as List?)
        ?.map((n) => TargetNote.fromJson(n as Map<String, dynamic>))
        .toList() ?? [],
  );
}
