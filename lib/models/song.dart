class Song {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String difficulty;
  final Duration duration;
  final List<LyricLine> lyrics;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.difficulty,
    required this.duration,
    this.lyrics = const [],
  });

  String get durationLabel {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}

class LyricLine {
  final int t; // percentage of song duration
  final String text;
  final String part; // A, B, BOTH

  const LyricLine({
    required this.t,
    required this.text,
    this.part = 'BOTH',
  });
}

/// Fixture songs for testing
const fixtureSongs = [
  Song(
    id: 'neon-midnight',
    title: 'Neon Midnight',
    artist: 'Vela Cruz',
    genre: 'Pop',
    difficulty: 'Medium',
    duration: Duration(minutes: 3, seconds: 42),
    lyrics: [
      LyricLine(t: 5, text: "We were never meant to last this long"),
      LyricLine(t: 15, text: "Dancing in the neon midnight glow"),
      LyricLine(t: 25, text: "Every heartbeat tells a different song"),
      LyricLine(t: 35, text: "We were never meant to last this long"),
      LyricLine(t: 45, text: "But here we are, just proving them wrong"),
      LyricLine(t: 55, text: "Shadows fall but we still hold on tight"),
      LyricLine(t: 65, text: "Through the darkness, we become the light"),
      LyricLine(t: 80, text: "This is our neon midnight"),
      LyricLine(t: 92, text: "We'll dance until the morning light"),
    ],
  ),
  Song(
    id: 'concrete-halo',
    title: 'Concrete Halo',
    artist: 'The Static Kings',
    genre: 'Rock',
    difficulty: 'Hard',
    duration: Duration(minutes: 4, seconds: 15),
  ),
  Song(
    id: 'loose-change',
    title: 'Loose Change',
    artist: 'Kobi Blaze',
    genre: 'Hip Hop',
    difficulty: 'Easy',
    duration: Duration(minutes: 2, seconds: 58),
  ),
  Song(
    id: 'slow-gold',
    title: 'Slow Gold',
    artist: 'Amara Reign',
    genre: 'R&B',
    difficulty: 'Medium',
    duration: Duration(minutes: 3, seconds: 30),
  ),
  Song(
    id: 'higher-ground',
    title: 'Higher Ground Hallelujah',
    artist: 'Sunday Choir Union',
    genre: 'Gospel',
    difficulty: 'Hard',
    duration: Duration(minutes: 5, seconds: 12),
  ),
  Song(
    id: 'yene-fikir',
    title: 'Yene Fikir Tizita',
    artist: 'Selam Tadesse',
    genre: 'Ethiopian',
    difficulty: 'Medium',
    duration: Duration(minutes: 4, seconds: 5),
  ),
  Song(
    id: 'tequila-sunrise',
    title: 'Tequila Sunrise Radio',
    artist: 'Marisol Vane',
    genre: 'Party',
    difficulty: 'Easy',
    duration: Duration(minutes: 3, seconds: 20),
  ),
  Song(
    id: 'old-sepia',
    title: 'Old Sepia Letters',
    artist: 'Frank Delacroix',
    genre: 'Classics',
    difficulty: 'Hard',
    duration: Duration(minutes: 4, seconds: 45),
  ),
];
