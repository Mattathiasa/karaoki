import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'app_config.dart';

/// One completed performance, persisted under performances/{id}.
class PerformanceRecord {
  final String songId;
  final String songTitle;
  final String singerId;
  final int score;
  final int pitch;
  final int timing;
  final int consistency;
  final int energy;
  final String? roomId;
  final DateTime performedAt;

  const PerformanceRecord({
    required this.songId,
    required this.songTitle,
    required this.singerId,
    required this.score,
    required this.pitch,
    required this.timing,
    required this.consistency,
    required this.energy,
    this.roomId,
    required this.performedAt,
  });

  Map<String, dynamic> toJson() => {
    'songId': songId,
    'songTitle': songTitle,
    'singerId': singerId,
    'score': score,
    'pitch': pitch,
    'timing': timing,
    'consistency': consistency,
    'energy': energy,
    'roomId': roomId,
    'performedAt': performedAt.millisecondsSinceEpoch,
  };
}

/// Persists finished performances so history/leaderboard screens have real
/// data. Writes to Firebase Realtime Database under performances/{pushId}
/// when Firebase is configured; otherwise logs and skips (no local store
/// wired yet, so history is server-side only).
class PerformanceHistoryService {
  FirebaseDatabase? _db;

  DatabaseReference? get _performancesRef {
    if (!AppConfig.isFirebaseConfigured) return null;
    try {
      return (_db ??= FirebaseDatabase.instance).ref('performances');
    } catch (e) {
      return null;
    }
  }

  /// Persist a finished performance. Returns the record id, or null when
  /// persistence is unavailable (Firebase not configured).
  Future<String?> savePerformance(PerformanceRecord record) async {
    final ref = _performancesRef;
    if (ref == null) {
      debugPrint(
        'PerformanceHistoryService: Firebase not configured, '
        'skipping history write for "${record.songTitle}"',
      );
      return null;
    }
    try {
      final id = ref.push().key;
      if (id == null) return null;
      await ref.child(id).set(record.toJson());
      return id;
    } catch (e) {
      debugPrint('PerformanceHistoryService: failed to save: $e');
      return null;
    }
  }
}
