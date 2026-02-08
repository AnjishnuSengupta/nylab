/// Nylab - User Repository
///
/// Repository for user data, watch history, and cloud sync
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Sync status for offline support
enum SyncStatus { synced, pending, error, offline }

/// Watch history entry for API sync
class WatchHistoryEntry {
  final String animeId;
  final String animeSlug;
  final String animeTitle;
  final String? animePoster;
  final int episodeNumber;
  final DateTime watchedAt;
  final double progressPercent;
  final bool isCompleted;

  WatchHistoryEntry({
    required this.animeId,
    required this.animeSlug,
    required this.animeTitle,
    this.animePoster,
    required this.episodeNumber,
    required this.watchedAt,
    this.progressPercent = 0.0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'animeSlug': animeSlug,
    'animeTitle': animeTitle,
    'animePoster': animePoster,
    'episodeNum': episodeNumber,
    'watchedAt': watchedAt.toIso8601String(),
    'progressPercent': progressPercent,
    'isCompleted': isCompleted,
  };

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WatchHistoryEntry(
      animeId: json['animeId'] as String? ?? json['animeSlug'] as String? ?? '',
      animeSlug:
          json['animeSlug'] as String? ?? json['animeId'] as String? ?? '',
      animeTitle: json['animeTitle'] as String? ?? '',
      animePoster: json['animePoster'] as String?,
      episodeNumber:
          json['episodeNum'] as int? ?? json['episodeNumber'] as int? ?? 0,
      watchedAt: json['watchedAt'] != null
          ? DateTime.tryParse(json['watchedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

/// User repository interface
abstract class UserRepository {
  Future<void> initialize();
  Future<String?> signInAnonymously();
  String? get userId;
  bool get isSignedIn;

  Future<List<WatchHistoryEntry>> getWatchHistory();
  Future<WatchHistoryEntry?> getLastWatched(String animeSlug);
  Future<void> updateWatchProgress(WatchHistoryEntry entry);
  Future<List<WatchHistoryEntry>> getContinueWatching();

  Future<List<WatchlistItem>> getWatchlist();
  Future<void> toggleWatchlist(WatchlistItem item);
  Future<bool> isInWatchlist(String animeId);

  Future<void> syncToCloud();
  Future<void> syncFromCloud();
  DateTime? get lastSyncTime;
  SyncStatus get syncStatus;

  void clearLocalData();
}

/// Firebase-backed user repository
class FirebaseUserRepository implements UserRepository {
  FirebaseAuth? _authOverride;
  FirebaseFirestore? _firestoreOverride;
  final Dio _dio;

  /// Lazily access FirebaseAuth — returns null if Firebase is not initialized
  FirebaseAuth? get _authOrNull {
    if (_authOverride != null) return _authOverride;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Lazily access FirebaseFirestore — returns null if Firebase is not initialized
  FirebaseFirestore? get _firestoreOrNull {
    if (_firestoreOverride != null) return _firestoreOverride;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  late Box<WatchlistItem> _watchlistBox;
  late Box<dynamic> _historyBox;
  late Box<dynamic> _settingsBox;
  bool _isInitialized = false;

  DateTime? _lastSyncTime;
  SyncStatus _syncStatus = SyncStatus.synced;

  static const String _baseUrl = 'https://nyanime-backend-v2.onrender.com';
  static const Duration _historyCacheTTL = Duration(hours: 24);

  FirebaseUserRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Dio? dio,
  }) : _authOverride = auth,
       _firestoreOverride = firestore,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
             ),
           );

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _watchlistBox = await Hive.openBox<WatchlistItem>('watchlist');
    _historyBox = await Hive.openBox('watch_history');
    _settingsBox = await Hive.openBox('user_settings');

    // Load last sync time
    final lastSyncStr = _settingsBox.get('last_sync_time') as String?;
    if (lastSyncStr != null) {
      _lastSyncTime = DateTime.tryParse(lastSyncStr);
    }

    _isInitialized = true;
  }

  @override
  Future<String?> signInAnonymously() async {
    try {
      final auth = _authOrNull;
      if (auth == null) return null;
      final credential = await auth.signInAnonymously();
      return credential.user?.uid;
    } catch (e) {
      print('[UserRepository] Anonymous sign-in error: $e');
      return null;
    }
  }

  @override
  String? get userId => _authOrNull?.currentUser?.uid;

  @override
  bool get isSignedIn => _authOrNull?.currentUser != null;

  @override
  DateTime? get lastSyncTime => _lastSyncTime;

  @override
  SyncStatus get syncStatus => _syncStatus;

  /// Get formatted "last synced" string
  String get lastSyncedAgo {
    if (_lastSyncTime == null) return 'Never synced';
    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Future<List<WatchHistoryEntry>> getWatchHistory() async {
    await initialize();

    // Try to get from local cache first
    final cached = _getCachedHistory();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // If signed in, fetch from backend
    if (isSignedIn) {
      try {
        final response = await _dio.get(
          '/api/cli/history',
          options: Options(headers: {'X-Firebase-UID': userId}),
        );

        if (response.data != null) {
          final data = response.data;
          final historyData = data is Map && data.containsKey('data')
              ? data['data']
              : data;

          if (historyData is List) {
            final history = historyData
                .map(
                  (e) => WatchHistoryEntry.fromJson(e as Map<String, dynamic>),
                )
                .toList();
            _cacheHistory(history);
            return history;
          }
        }
      } catch (e) {
        print('[UserRepository] getWatchHistory error: $e');
        _syncStatus = SyncStatus.error;
      }
    }

    // Return cached or empty list
    return cached ?? [];
  }

  @override
  Future<WatchHistoryEntry?> getLastWatched(String animeSlug) async {
    final history = await getWatchHistory();
    final entries = history.where((e) => e.animeSlug == animeSlug).toList();
    if (entries.isEmpty) return null;
    entries.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    return entries.first;
  }

  @override
  Future<void> updateWatchProgress(WatchHistoryEntry entry) async {
    await initialize();

    // Save locally first
    _saveLocalHistory(entry);

    // Sync to backend if signed in
    if (isSignedIn) {
      try {
        await _dio.post(
          '/api/cli/sync-watch',
          data: {
            'animeSlug': entry.animeSlug,
            'animeTitle': entry.animeTitle,
            'episodeNum': entry.episodeNumber,
          },
          options: Options(headers: {'X-Firebase-UID': userId}),
        );
        _syncStatus = SyncStatus.synced;
        _lastSyncTime = DateTime.now();
        await _settingsBox.put(
          'last_sync_time',
          _lastSyncTime!.toIso8601String(),
        );
      } catch (e) {
        print('[UserRepository] updateWatchProgress sync error: $e');
        _syncStatus = SyncStatus.pending;
      }
    } else {
      _syncStatus = SyncStatus.offline;
    }
  }

  @override
  Future<List<WatchHistoryEntry>> getContinueWatching() async {
    final history = await getWatchHistory();

    // Group by anime, get latest episode per anime
    final Map<String, WatchHistoryEntry> latestByAnime = {};
    for (final entry in history) {
      final existing = latestByAnime[entry.animeSlug];
      if (existing == null || entry.watchedAt.isAfter(existing.watchedAt)) {
        latestByAnime[entry.animeSlug] = entry;
      }
    }

    // Sort by most recently watched
    final continueWatching = latestByAnime.values.toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));

    // Return top 20 not completed
    return continueWatching
        .where((e) => !e.isCompleted && e.progressPercent < 0.95)
        .take(20)
        .toList();
  }

  @override
  Future<List<WatchlistItem>> getWatchlist() async {
    await initialize();

    // If signed in, try to sync from Firestore
    if (isSignedIn) {
      try {
        final firestore = _firestoreOrNull;
        if (firestore == null) throw Exception('Firestore not available');
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('watchlist')
            .orderBy('addedAt', descending: true)
            .get();

        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          return WatchlistItem(
            animeId: int.tryParse(doc.id) ?? 0,
            animeTitle: data['animeTitle'] as String? ?? '',
            animePosterUrl: data['animePosterUrl'] as String? ?? '',
            addedAt:
                (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            status: WatchlistStatus.values.firstWhere(
              (s) => s.name == (data['status'] as String? ?? 'planToWatch'),
              orElse: () => WatchlistStatus.planToWatch,
            ),
            userScore: data['userScore'] as int?,
            episodesWatched: data['episodesWatched'] as int? ?? 0,
            totalEpisodes: data['totalEpisodes'] as int?,
          );
        }).toList();

        // Cache locally
        for (final item in items) {
          await _watchlistBox.put(item.animeId.toString(), item);
        }

        return items;
      } catch (e) {
        print('[UserRepository] getWatchlist error: $e');
      }
    }

    // Return local watchlist
    return _watchlistBox.values.toList();
  }

  @override
  Future<void> toggleWatchlist(WatchlistItem item) async {
    await initialize();

    final key = item.animeId.toString();
    final exists = _watchlistBox.containsKey(key);

    if (exists) {
      // Remove from watchlist
      await _watchlistBox.delete(key);

      if (isSignedIn) {
        try {
          final firestore = _firestoreOrNull;
          if (firestore == null) throw Exception('Firestore not available');
          await firestore
              .collection('users')
              .doc(userId)
              .collection('watchlist')
              .doc(key)
              .delete();
        } catch (e) {
          print('[UserRepository] Remove from Firestore error: $e');
        }
      }
    } else {
      // Add to watchlist
      await _watchlistBox.put(key, item);

      if (isSignedIn) {
        try {
          final firestore = _firestoreOrNull;
          if (firestore == null) throw Exception('Firestore not available');
          await firestore
              .collection('users')
              .doc(userId)
              .collection('watchlist')
              .doc(key)
              .set({
                'animeId': item.animeId,
                'animeTitle': item.animeTitle,
                'animePosterUrl': item.animePosterUrl,
                'addedAt': Timestamp.fromDate(item.addedAt),
                'status': item.status.name,
                'userScore': item.userScore,
                'episodesWatched': item.episodesWatched,
                'totalEpisodes': item.totalEpisodes,
              });
        } catch (e) {
          print('[UserRepository] Add to Firestore error: $e');
        }
      }
    }
  }

  @override
  Future<bool> isInWatchlist(String animeId) async {
    await initialize();
    return _watchlistBox.containsKey(animeId);
  }

  @override
  Future<void> syncToCloud() async {
    if (!isSignedIn) {
      _syncStatus = SyncStatus.offline;
      return;
    }

    try {
      _syncStatus = SyncStatus.pending;

      // Sync watchlist to Firestore
      final watchlist = _watchlistBox.values.toList();
      final firestore = _firestoreOrNull;
      if (firestore == null) {
        _syncStatus = SyncStatus.offline;
        return;
      }
      final batch = firestore.batch();

      for (final item in watchlist) {
        final docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('watchlist')
            .doc(item.animeId.toString());

        batch.set(docRef, {
          'animeId': item.animeId,
          'animeTitle': item.animeTitle,
          'animePosterUrl': item.animePosterUrl,
          'addedAt': Timestamp.fromDate(item.addedAt),
          'status': item.status.name,
          'userScore': item.userScore,
          'episodesWatched': item.episodesWatched,
          'totalEpisodes': item.totalEpisodes,
        });
      }

      await batch.commit();

      _lastSyncTime = DateTime.now();
      await _settingsBox.put(
        'last_sync_time',
        _lastSyncTime!.toIso8601String(),
      );
      _syncStatus = SyncStatus.synced;
    } catch (e) {
      print('[UserRepository] syncToCloud error: $e');
      _syncStatus = SyncStatus.error;
    }
  }

  @override
  Future<void> syncFromCloud() async {
    if (!isSignedIn) {
      _syncStatus = SyncStatus.offline;
      return;
    }

    try {
      _syncStatus = SyncStatus.pending;

      // Sync watchlist from Firestore
      await getWatchlist();

      // Sync watch history from backend
      await getWatchHistory();

      _lastSyncTime = DateTime.now();
      await _settingsBox.put(
        'last_sync_time',
        _lastSyncTime!.toIso8601String(),
      );
      _syncStatus = SyncStatus.synced;
    } catch (e) {
      print('[UserRepository] syncFromCloud error: $e');
      _syncStatus = SyncStatus.error;
    }
  }

  @override
  void clearLocalData() {
    _watchlistBox.clear();
    _historyBox.clear();
    _settingsBox.delete('last_sync_time');
    _lastSyncTime = null;
    _syncStatus = SyncStatus.synced;
  }

  // Local cache helpers
  List<WatchHistoryEntry>? _getCachedHistory() {
    try {
      final timestampStr = _historyBox.get('history_timestamp') as String?;
      if (timestampStr == null) return null;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return null;

      if (DateTime.now().difference(timestamp) > _historyCacheTTL) {
        return null;
      }

      final dataJson = _historyBox.get('history_data') as String?;
      if (dataJson == null) return null;

      final dataList = jsonDecode(dataJson) as List;
      return dataList
          .map((e) => WatchHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  void _cacheHistory(List<WatchHistoryEntry> history) {
    try {
      _historyBox.put('history_timestamp', DateTime.now().toIso8601String());
      _historyBox.put(
        'history_data',
        jsonEncode(history.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      print('[UserRepository] Cache history error: $e');
    }
  }

  void _saveLocalHistory(WatchHistoryEntry entry) {
    try {
      final existing = _getCachedHistory() ?? [];
      final updated = [
        entry,
        ...existing.where(
          (e) =>
              !(e.animeSlug == entry.animeSlug &&
                  e.episodeNumber == entry.episodeNumber),
        ),
      ];
      _cacheHistory(updated.take(500).toList()); // Keep last 500 entries
    } catch (e) {
      print('[UserRepository] Save local history error: $e');
    }
  }
}

/// Singleton instance
final userRepository = FirebaseUserRepository();
