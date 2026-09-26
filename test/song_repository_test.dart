import 'package:flutter_test/flutter_test.dart';
import 'package:karaoki/models/song.dart';
import 'package:karaoki/services/song_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SongRepository', () {
    test('byId returns a song with lyrics loaded from its LRC asset', () async {
      final song = await SongRepository.instance.byId('neon-midnight');

      expect(song, isNotNull);
      expect(song!.title, 'Neon Midnight');
      // Lyrics must come from the LRC asset, not be empty.
      expect(song.lyrics, isNotEmpty);
      expect(song.lyrics.first.text, 'We were never meant to last this long');
    });

    test('byId returns null for an unknown id', () async {
      expect(await SongRepository.instance.byId('no-such-song'), isNull);
    });

    test('byGenre filters case-insensitively and "all" returns everything',
        () async {
      final pop = await SongRepository.instance.byGenre('pop');
      expect(pop, isNotEmpty);
      expect(pop.every((s) => s.genre.toLowerCase() == 'pop'), isTrue);

      final all = await SongRepository.instance.byGenre('all');
      expect(all.length, fixtureSongs.length);
    });

    test('search matches title or artist case-insensitively', () async {
      final byTitle = await SongRepository.instance.search('neon');
      expect(byTitle.map((s) => s.id), contains('neon-midnight'));

      final byArtist = await SongRepository.instance.search('vela');
      expect(byArtist.map((s) => s.id), contains('neon-midnight'));

      expect(await SongRepository.instance.search('zzz-nothing'), isEmpty);
    });

    test('all() loads every catalogue song with lyrics', () async {
      final songs = await SongRepository.instance.all();
      expect(songs.length, fixtureSongs.length);
      for (final song in songs) {
        expect(song.lyrics, isNotEmpty, reason: '${song.id} has no lyrics');
      }
    });

    test('Song JSON round-trips through toJson/fromJson', () {
      const song = Song(
        id: 'round-trip',
        title: 'Round Trip',
        artist: 'Tester',
        genre: 'Pop',
        difficulty: 'Easy',
        duration: Duration(minutes: 2, seconds: 30),
        audioUrl: 'assets/audio/round-trip.mp3',
        lrcAsset: 'assets/lyrics/round-trip.lrc',
      );

      final restored = Song.fromJson(song.toJson());

      expect(restored.id, song.id);
      expect(restored.title, song.title);
      expect(restored.duration, song.duration);
      expect(restored.audioUrl, song.audioUrl);
      expect(restored.lrcAsset, song.lrcAsset);
      expect(restored.lyrics, isEmpty); // derived from LRC at runtime
    });
  });
}
