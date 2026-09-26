import 'note_track.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String difficulty;
  final Duration duration;
  final List<LyricLine> lyrics;
  final NoteTrack? noteTrack;
  /// HTTP/HTTPS URL or local asset path for the backing track.
  final String? audioUrl;
  /// Asset path for the LRC lyric file, e.g. `assets/lyrics/neon-midnight.lrc`.
  /// SongRepository reads this and populates [lyrics] at load time.
  final String? lrcAsset;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.difficulty,
    required this.duration,
    this.lyrics = const [],
    this.noteTrack,
    this.audioUrl,
    this.lrcAsset,
  });

  String get durationLabel {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  // ── Serialization ────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'genre': genre,
        'difficulty': difficulty,
        'durationMs': duration.inMilliseconds,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (lrcAsset != null) 'lrcAsset': lrcAsset,
        if (noteTrack != null) 'noteTrack': noteTrack!.toJson(),
        // lyrics are derived from the LRC asset at runtime — not persisted
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
        genre: json['genre'] as String,
        difficulty: json['difficulty'] as String,
        duration: Duration(milliseconds: (json['durationMs'] as num).toInt()),
        audioUrl: json['audioUrl'] as String?,
        lrcAsset: json['lrcAsset'] as String?,
        noteTrack: json['noteTrack'] != null
            ? NoteTrack.fromJson(json['noteTrack'] as Map<String, dynamic>)
            : null,
      );
}

class LyricLine {
  final int t; // percentage of song duration
  final String text;
  final String part; // A, B, BOTH

  const LyricLine({required this.t, required this.text, this.part = 'BOTH'});

  /// Syllable-like vowel clusters in this line, used to derive the expected
  /// singing pace (syllables per second) for the speed metric.
  int get syllableCount {
    var count = 0;
    for (final word in text.split(RegExp(r'[^a-zA-Z]+'))) {
      if (word.isEmpty) continue;
      final clusters = RegExp(r'[aeiouy]+', caseSensitive: false)
          .allMatches(word)
          .length;
      count += clusters > 0 ? clusters : 1; // Vowel-less words count once.
    }
    return count;
  }

  /// Expected syllables per second when sung over [lineDurationSeconds].
  double syllablesPerSecond(double lineDurationSeconds) {
    if (lineDurationSeconds <= 0) return 0;
    return syllableCount / lineDurationSeconds;
  }

  Map<String, dynamic> toJson() => {
        't': t,
        'text': text,
        'part': part,
      };

  factory LyricLine.fromJson(Map<String, dynamic> json) => LyricLine(
        t: (json['t'] as num).toInt(),
        text: json['text'] as String,
        part: json['part'] as String? ?? 'BOTH',
      );
}

/// Fixture songs — the catalogue used throughout the app.
/// Each entry points at its LRC asset; SongRepository loads and parses
/// the lyrics at runtime so we never have to duplicate them here.
const fixtureSongs = [
  Song(
    id: 'neon-midnight',
    title: 'Neon Midnight',
    artist: 'Vela Cruz',
    genre: 'Pop',
    difficulty: 'Medium',
    duration: Duration(minutes: 3, seconds: 42),
    lrcAsset: 'assets/lyrics/neon-midnight.lrc',
    noteTrack: NoteTrack(songId: 'neon-midnight', notes: [
      TargetNote(t: 5, hz: 330, durationPercent: 8),   // E4
      TargetNote(t: 15, hz: 392, durationPercent: 8),  // G4
      TargetNote(t: 25, hz: 440, durationPercent: 8),  // A4
      TargetNote(t: 35, hz: 330, durationPercent: 8),  // E4
      TargetNote(t: 45, hz: 349, durationPercent: 8),  // F4
      TargetNote(t: 55, hz: 392, durationPercent: 8),  // G4
      TargetNote(t: 65, hz: 440, durationPercent: 10), // A4
      TargetNote(t: 80, hz: 523, durationPercent: 10), // C5
      TargetNote(t: 92, hz: 494, durationPercent: 6),  // B4
    ]),
  ),
  Song(
    id: 'concrete-halo',
    title: 'Concrete Halo',
    artist: 'The Static Kings',
    genre: 'Rock',
    difficulty: 'Hard',
    duration: Duration(minutes: 4, seconds: 15),
    lrcAsset: 'assets/lyrics/concrete-halo.lrc',
    noteTrack: NoteTrack(songId: 'concrete-halo', notes: [
      TargetNote(t: 8, hz: 220, durationPercent: 6),   // A3
      TargetNote(t: 16, hz: 262, durationPercent: 6),  // C4
      TargetNote(t: 24, hz: 294, durationPercent: 6),  // D4
      TargetNote(t: 32, hz: 330, durationPercent: 6),  // E4
      TargetNote(t: 40, hz: 294, durationPercent: 8),  // D4
      TargetNote(t: 48, hz: 262, durationPercent: 6),  // C4
      TargetNote(t: 56, hz: 220, durationPercent: 8),  // A3
      TargetNote(t: 64, hz: 196, durationPercent: 8),  // G3
    ]),
  ),
  Song(
    id: 'loose-change',
    title: 'Loose Change',
    artist: 'Kobi Blaze',
    genre: 'Hip Hop',
    difficulty: 'Easy',
    duration: Duration(minutes: 2, seconds: 58),
    lrcAsset: 'assets/lyrics/loose-change.lrc',
    noteTrack: NoteTrack(songId: 'loose-change', notes: [
      TargetNote(t: 5, hz: 294, durationPercent: 5),   // D4
      TargetNote(t: 10, hz: 330, durationPercent: 5),  // E4
      TargetNote(t: 15, hz: 294, durationPercent: 5),  // D4
      TargetNote(t: 20, hz: 262, durationPercent: 5),  // C4
      TargetNote(t: 25, hz: 294, durationPercent: 8),  // D4
      TargetNote(t: 35, hz: 330, durationPercent: 5),  // E4
      TargetNote(t: 40, hz: 349, durationPercent: 5),  // F4
      TargetNote(t: 48, hz: 330, durationPercent: 5),  // E4
    ]),
  ),
  Song(
    id: 'slow-gold',
    title: 'Slow Gold',
    artist: 'Amara Reign',
    genre: 'R&B',
    difficulty: 'Medium',
    duration: Duration(minutes: 3, seconds: 30),
    lrcAsset: 'assets/lyrics/slow-gold.lrc',
    noteTrack: NoteTrack(songId: 'slow-gold', notes: [
      TargetNote(t: 6, hz: 330, durationPercent: 7),   // E4
      TargetNote(t: 14, hz: 349, durationPercent: 7),  // F4
      TargetNote(t: 22, hz: 392, durationPercent: 7),  // G4
      TargetNote(t: 30, hz: 440, durationPercent: 7),  // A4
      TargetNote(t: 38, hz: 392, durationPercent: 7),  // G4
      TargetNote(t: 46, hz: 349, durationPercent: 7),  // F4
      TargetNote(t: 54, hz: 330, durationPercent: 8),  // E4
      TargetNote(t: 62, hz: 294, durationPercent: 8),  // D4
    ]),
  ),
  Song(
    id: 'higher-ground',
    title: 'Higher Ground Hallelujah',
    artist: 'Sunday Choir Union',
    genre: 'Gospel',
    difficulty: 'Hard',
    duration: Duration(minutes: 5, seconds: 12),
    lrcAsset: 'assets/lyrics/higher-ground.lrc',
    noteTrack: NoteTrack(songId: 'higher-ground', notes: [
      TargetNote(t: 8, hz: 262, durationPercent: 6),   // C4
      TargetNote(t: 16, hz: 330, durationPercent: 6),  // E4
      TargetNote(t: 24, hz: 392, durationPercent: 6),  // G4
      TargetNote(t: 32, hz: 523, durationPercent: 8),  // C5
      TargetNote(t: 40, hz: 494, durationPercent: 6),  // B4
      TargetNote(t: 48, hz: 440, durationPercent: 6),  // A4
      TargetNote(t: 56, hz: 392, durationPercent: 8),  // G4
      TargetNote(t: 64, hz: 330, durationPercent: 8),  // E4
    ]),
  ),
  Song(
    id: 'yene-fikir',
    title: 'Yene Fikir Tizita',
    artist: 'Selam Tadesse',
    genre: 'Ethiopian',
    difficulty: 'Medium',
    duration: Duration(minutes: 4, seconds: 5),
    lrcAsset: 'assets/lyrics/yene-fikir.lrc',
    noteTrack: NoteTrack(songId: 'yene-fikir', notes: [
      TargetNote(t: 8, hz: 294, durationPercent: 7),   // D4
      TargetNote(t: 16, hz: 330, durationPercent: 7),  // E4
      TargetNote(t: 24, hz: 370, durationPercent: 7),  // F#4
      TargetNote(t: 32, hz: 440, durationPercent: 8),  // A4
      TargetNote(t: 40, hz: 392, durationPercent: 7),  // G4
      TargetNote(t: 48, hz: 330, durationPercent: 7),  // E4
      TargetNote(t: 56, hz: 294, durationPercent: 8),  // D4
      TargetNote(t: 64, hz: 262, durationPercent: 8),  // C4
    ]),
  ),
  Song(
    id: 'tequila-sunrise',
    title: 'Tequila Sunrise Radio',
    artist: 'Marisol Vane',
    genre: 'Party',
    difficulty: 'Easy',
    duration: Duration(minutes: 3, seconds: 20),
    lrcAsset: 'assets/lyrics/tequila-sunrise.lrc',
    noteTrack: NoteTrack(songId: 'tequila-sunrise', notes: [
      TargetNote(t: 5, hz: 330, durationPercent: 5),   // E4
      TargetNote(t: 11, hz: 349, durationPercent: 5),  // F4
      TargetNote(t: 17, hz: 392, durationPercent: 5),  // G4
      TargetNote(t: 23, hz: 440, durationPercent: 5),  // A4
      TargetNote(t: 29, hz: 392, durationPercent: 5),  // G4
      TargetNote(t: 35, hz: 349, durationPercent: 5),  // F4
      TargetNote(t: 41, hz: 330, durationPercent: 6),  // E4
      TargetNote(t: 47, hz: 294, durationPercent: 6),  // D4
    ]),
  ),
  Song(
    id: 'old-sepia',
    title: 'Old Sepia Letters',
    artist: 'Frank Delacroix',
    genre: 'Classics',
    difficulty: 'Hard',
    duration: Duration(minutes: 4, seconds: 45),
    lrcAsset: 'assets/lyrics/old-sepia.lrc',
    noteTrack: NoteTrack(songId: 'old-sepia', notes: [
      TargetNote(t: 10, hz: 262, durationPercent: 7),   // C4
      TargetNote(t: 18, hz: 294, durationPercent: 7),  // D4
      TargetNote(t: 26, hz: 330, durationPercent: 7),  // E4
      TargetNote(t: 34, hz: 392, durationPercent: 8),  // G4
      TargetNote(t: 42, hz: 440, durationPercent: 7),  // A4
      TargetNote(t: 50, hz: 392, durationPercent: 7),  // G4
      TargetNote(t: 58, hz: 330, durationPercent: 7),  // E4
      TargetNote(t: 66, hz: 262, durationPercent: 8),  // C4
    ]),
  ),
];
