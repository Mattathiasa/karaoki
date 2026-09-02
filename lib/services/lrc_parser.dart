import '../models/song.dart';

/// Parses standard LRC lyric files into LyricLine objects.
///
/// LRC format:
///   [mm:ss.xx] text
///   [mm:ss.xxx] text
///   [mm:ss] text
///
/// Extended LRC supports per-line metadata:
///   [mm:ss.xx] <part=A> text
///   [mm:ss.xx] <part=B> text
///   [mm:ss.xx] <part=BOTH> text
///
/// Also supports [ti:], [ar:], [al:], [offset:] metadata tags.
class LrcParser {
  /// Parse an LRC string into a list of LyricLine objects.
  ///
  /// [totalDuration] is the song's total duration, used to convert
  /// absolute timestamps to percentage-based timing for our model.
  static List<LyricLine> parse(String lrcContent, {required Duration totalDuration}) {
    final lines = <LyricLine>[];
    final totalMs = totalDuration.inMilliseconds;
    if (totalMs <= 0) return lines;

    for (final raw in lrcContent.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      // Skip metadata tags like [ti:Song Name]
      if (RegExp(r'^\[[a-zA-Z]+:').hasMatch(line)) continue;

      // Match timestamp(s): [mm:ss.xx] or [mm:ss.xxx] or [mm:ss]
      final timestampMatches = RegExp(r'\[(\d+):(\d+)(?:\.(\d+))?\]').allMatches(line);
      if (timestampMatches.isEmpty) continue;

      // Extract text after all timestamps
      final text = line.replaceAll(RegExp(r'\[[\d:.]+\]'), '').trim();
      if (text.isEmpty) continue;

      // Check for extended LRC part tags: <part=A>, <part=B>, <part=BOTH>
      String part = 'BOTH';
      final partMatch = RegExp(r'<part=(\w+)>').firstMatch(text);
      if (partMatch != null) {
        part = partMatch.group(1)!;
      }
      final cleanText = text.replaceAll(RegExp(r'<part=\w+>'), '').trim();
      if (cleanText.isEmpty) continue;

      // Parse each timestamp and create a LyricLine
      for (final ts in timestampMatches) {
        final minutes = int.parse(ts.group(1)!);
        final seconds = int.parse(ts.group(2)!);
        final millis = _parseMilliseconds(ts.group(3));

        final absoluteMs = (minutes * 60 * 1000) + (seconds * 1000) + millis;
        final percentage = ((absoluteMs / totalMs) * 100).round().clamp(0, 100);

        lines.add(LyricLine(
          t: percentage,
          text: cleanText,
          part: part,
        ));
      }
    }

    // Sort by timestamp
    lines.sort((a, b) => a.t.compareTo(b.t));
    return lines;
  }

  /// Parse an LRC file string and return metadata + lyrics.
  static LrcParseResult parseWithMetadata(String lrcContent, {required Duration totalDuration}) {
    String? title;
    String? artist;
    String? album;
    int offsetMs = 0;

    for (final raw in lrcContent.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      final tiMatch = RegExp(r'^\[ti:(.+)\]$').firstMatch(line);
      if (tiMatch != null) { title = tiMatch.group(1)!.trim(); continue; }

      final arMatch = RegExp(r'^\[ar:(.+)\]$').firstMatch(line);
      if (arMatch != null) { artist = arMatch.group(1)!.trim(); continue; }

      final alMatch = RegExp(r'^\[al:(.+)\]$').firstMatch(line);
      if (alMatch != null) { album = alMatch.group(1)!.trim(); continue; }

      final offsetMatch = RegExp(r'^\[offset:([+-]?\d+)\]$').firstMatch(line);
      if (offsetMatch != null) { offsetMs = int.parse(offsetMatch.group(1)!); continue; }
    }

    final lyrics = parse(lrcContent, totalDuration: totalDuration);

    return LrcParseResult(
      title: title,
      artist: artist,
      album: album,
      offsetMs: offsetMs,
      lyrics: lyrics,
    );
  }

  /// Parse the fractional seconds part of a timestamp.
  /// Handles both 2-digit (xx = centiseconds) and 3-digit (xxx = milliseconds).
  static int _parseMilliseconds(String? fraction) {
    if (fraction == null || fraction.isEmpty) return 0;
    if (fraction.length == 2) {
      // Centiseconds: multiply by 10
      return int.parse(fraction) * 10;
    } else if (fraction.length == 3) {
      return int.parse(fraction);
    } else if (fraction.length == 1) {
      return int.parse(fraction) * 100;
    }
    return 0;
  }

  /// Generate a sample LRC string from existing LyricLine data (for development).
  static String toLrc(List<LyricLine> lyrics, Duration totalDuration, {
    String? title,
    String? artist,
  }) {
    final buf = StringBuffer();
    if (title != null) buf.writeln('[ti:$title]');
    if (artist != null) buf.writeln('[ar:$artist]');
    buf.writeln('[by:karaoki]');
    buf.writeln();

    final totalMs = totalDuration.inMilliseconds;
    for (final line in lyrics) {
      final absoluteMs = (line.t / 100.0 * totalMs).round();
      final minutes = absoluteMs ~/ 60000;
      final seconds = (absoluteMs % 60000) ~/ 1000;
      final millis = absoluteMs % 1000;
      final ts = '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}.'
          '${millis.toString().padLeft(3, '0')}';

      if (line.part != 'BOTH') {
        buf.writeln('[$ts] <part=${line.part}> ${line.text}');
      } else {
        buf.writeln('[$ts] ${line.text}');
      }
    }

    return buf.toString();
  }
}

/// Result of parsing an LRC file with metadata.
class LrcParseResult {
  final String? title;
  final String? artist;
  final String? album;
  final int offsetMs;
  final List<LyricLine> lyrics;

  const LrcParseResult({
    this.title,
    this.artist,
    this.album,
    this.offsetMs = 0,
    this.lyrics = const [],
  });
}
