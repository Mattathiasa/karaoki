import 'package:flutter/services.dart' show rootBundle;
import '../models/song.dart';
import 'lrc_parser.dart';

/// Single source of truth for the song catalogue.
///
/// Loads each fixture song's LRC file from assets at first access so the
/// `Song` objects the rest of the app uses always have fully-parsed lyrics.
/// The repository is a singleton — call [SongRepository.instance].
class SongRepository {
  SongRepository._();
  static final SongRepository instance = SongRepository._();

  // Cache: song id → Song with lyrics loaded
  final Map<String, Song> _cache = {};

  // ── Public API ────────────────────────────────────────────────────────────

  /// All songs, fully loaded (lyrics populated from LRC assets).
  Future<List<Song>> all() async {
    for (final song in fixtureSongs) {
      await _ensureLoaded(song);
    }
    return _cache.values.toList();
  }

  /// A single song by id, fully loaded. Returns null when not found.
  Future<Song?> byId(String id) async {
    final base = fixtureSongs.cast<Song?>().firstWhere(
          (s) => s?.id == id,
          orElse: () => null,
        );
    if (base == null) return null;
    return _ensureLoaded(base);
  }

  /// All songs whose genre matches [genre] (case-insensitive).
  Future<List<Song>> byGenre(String genre) async {
    final all_ = await all();
    if (genre.toLowerCase() == 'all') return all_;
    return all_.where((s) => s.genre.toLowerCase() == genre.toLowerCase()).toList();
  }

  /// Songs whose title or artist contains [query] (case-insensitive).
  Future<List<Song>> search(String query) async {
    final q = query.toLowerCase();
    final all_ = await all();
    return all_.where((s) =>
        s.title.toLowerCase().contains(q) ||
        s.artist.toLowerCase().contains(q)).toList();
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  /// Return the cached song if already loaded, otherwise load its LRC.
  Future<Song> _ensureLoaded(Song base) async {
    if (_cache.containsKey(base.id)) return _cache[base.id]!;

    // Honor the song's declared asset, falling back to the id-derived path.
    final lrcAsset = base.lrcAsset ?? 'assets/lyrics/${base.id}.lrc';
    List<LyricLine> lyrics = base.lyrics;

    try {
      final lrcContent = await rootBundle.loadString(lrcAsset);
      lyrics = LrcParser.parse(lrcContent, totalDuration: base.duration);
    } catch (_) {
      // Asset not found or parse error: fall back to any inline lyrics or
      // the placeholder generator in KaraokePlaybackService.
    }

    final loaded = Song(
      id: base.id,
      title: base.title,
      artist: base.artist,
      genre: base.genre,
      difficulty: base.difficulty,
      duration: base.duration,
      lyrics: lyrics,
      noteTrack: base.noteTrack,
      audioUrl: base.audioUrl,
    );

    _cache[base.id] = loaded;
    return loaded;
  }
}
