/// NYAnime Mobile - Local Storage
///
/// Hive-based local storage for caching and offline support.
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../../core/constants/app_constants.dart';

class LocalStorage {
  static LocalStorage? _instance;

  late Box<dynamic> _cacheBox;
  late Box<dynamic> _userBox;
  late Box<dynamic> _watchlistBox;

  LocalStorage._();

  static LocalStorage get instance {
    _instance ??= LocalStorage._();
    return _instance!;
  }

  bool _isInitialized = false;

  /// Initialize Hive storage
  Future<void> init() async {
    if (_isInitialized) return;

    // Open boxes (Hive.initFlutter() should already be called in main)
    _cacheBox = await Hive.openBox(AppConstants.hiveCacheBox);
    _userBox = await Hive.openBox(AppConstants.hiveUserBox);
    _watchlistBox = await Hive.openBox(AppConstants.hiveWatchlistBox);

    _isInitialized = true;
  }

  /// Whether storage has been initialized
  bool get isInitialized => _isInitialized;

  // ============ Cache Operations ============

  /// Cache data with expiry
  Future<void> cache(String key, dynamic data, {Duration? expiry}) async {
    final expiryTime = DateTime.now().add(expiry ?? AppConstants.cacheExpiry);
    await _cacheBox.put(key, {
      'data': data,
      'expiry': expiryTime.toIso8601String(),
    });
  }

  /// Get cached data if not expired
  T? getCached<T>(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;

    final expiry = DateTime.parse(cached['expiry'] as String);
    if (DateTime.now().isAfter(expiry)) {
      _cacheBox.delete(key);
      return null;
    }

    return cached['data'] as T?;
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // ============ Watch Progress Operations ============

  /// Save watch progress
  Future<void> saveWatchProgress(WatchProgress progress) async {
    final key = 'progress_${progress.animeId}_${progress.episodeId}';
    await _userBox.put(key, {
      'animeId': progress.animeId,
      'episodeId': progress.episodeId,
      'episodeNumber': progress.episodeNumber,
      'watchedSeconds': progress.watchedDuration.inSeconds,
      'totalSeconds': progress.totalDuration.inSeconds,
      'lastWatchedAt': progress.lastWatchedAt.toIso8601String(),
      'isCompleted': progress.isCompleted,
    });
  }

  /// Get watch progress for an episode
  WatchProgress? getWatchProgress(int animeId, int episodeId) {
    final key = 'progress_${animeId}_$episodeId';
    final data = _userBox.get(key);
    if (data == null) return null;

    return WatchProgress(
      animeId: data['animeId'] as int,
      episodeId: data['episodeId'] as int,
      episodeNumber: data['episodeNumber'] as int,
      watchedDuration: Duration(seconds: data['watchedSeconds'] as int),
      totalDuration: Duration(seconds: data['totalSeconds'] as int),
      lastWatchedAt: DateTime.parse(data['lastWatchedAt'] as String),
      isCompleted: data['isCompleted'] as bool,
    );
  }

  /// Get all continue watching items
  List<WatchProgress> getContinueWatching() {
    final items = <WatchProgress>[];
    for (final key in _userBox.keys) {
      if ((key as String).startsWith('progress_')) {
        final data = _userBox.get(key);
        if (data != null && !(data['isCompleted'] as bool)) {
          items.add(
            WatchProgress(
              animeId: data['animeId'] as int,
              episodeId: data['episodeId'] as int,
              episodeNumber: data['episodeNumber'] as int,
              watchedDuration: Duration(seconds: data['watchedSeconds'] as int),
              totalDuration: Duration(seconds: data['totalSeconds'] as int),
              lastWatchedAt: DateTime.parse(data['lastWatchedAt'] as String),
              isCompleted: data['isCompleted'] as bool,
            ),
          );
        }
      }
    }
    items.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
    return items;
  }

  // ============ Watchlist Operations ============

  /// Add to watchlist
  Future<void> addToWatchlist(WatchlistItem item) async {
    await _watchlistBox.put(item.animeId, {
      'animeId': item.animeId,
      'animeTitle': item.animeTitle,
      'animePosterUrl': item.animePosterUrl,
      'addedAt': item.addedAt.toIso8601String(),
      'status': item.status.index,
      'userScore': item.userScore,
      'episodesWatched': item.episodesWatched,
      'totalEpisodes': item.totalEpisodes,
    });
  }

  /// Remove from watchlist
  Future<void> removeFromWatchlist(int animeId) async {
    await _watchlistBox.delete(animeId);
  }

  /// Get watchlist item
  WatchlistItem? getWatchlistItem(int animeId) {
    final data = _watchlistBox.get(animeId);
    if (data == null) return null;

    return WatchlistItem(
      animeId: data['animeId'] as int,
      animeTitle: data['animeTitle'] as String,
      animePosterUrl: data['animePosterUrl'] as String,
      addedAt: DateTime.parse(data['addedAt'] as String),
      status: WatchlistStatus.values[data['status'] as int],
      userScore: data['userScore'] as int?,
      episodesWatched: data['episodesWatched'] as int,
      totalEpisodes: data['totalEpisodes'] as int?,
    );
  }

  /// Get all watchlist items
  List<WatchlistItem> getWatchlist({WatchlistStatus? status}) {
    final items = <WatchlistItem>[];
    for (final key in _watchlistBox.keys) {
      final data = _watchlistBox.get(key);
      if (data != null) {
        final item = WatchlistItem(
          animeId: data['animeId'] as int,
          animeTitle: data['animeTitle'] as String,
          animePosterUrl: data['animePosterUrl'] as String,
          addedAt: DateTime.parse(data['addedAt'] as String),
          status: WatchlistStatus.values[data['status'] as int],
          userScore: data['userScore'] as int?,
          episodesWatched: data['episodesWatched'] as int,
          totalEpisodes: data['totalEpisodes'] as int?,
        );
        if (status == null || item.status == status) {
          items.add(item);
        }
      }
    }
    items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return items;
  }

  /// Check if anime is in watchlist
  bool isInWatchlist(int animeId) {
    return _watchlistBox.containsKey(animeId);
  }

  /// Update watchlist item
  Future<void> updateWatchlistItem(WatchlistItem item) async {
    await addToWatchlist(item);
  }

  // ============ User Settings Operations ============

  /// Save first launch completed
  Future<void> setOnboardingCompleted() async {
    await _userBox.put('onboarding_completed', true);
  }

  /// Check if onboarding completed
  bool isOnboardingCompleted() {
    return _userBox.get('onboarding_completed', defaultValue: false) as bool;
  }

  /// Save preferred playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    await _userBox.put('playback_speed', speed);
  }

  /// Get preferred playback speed
  double getPlaybackSpeed() {
    return _userBox.get('playback_speed', defaultValue: 1.0) as double;
  }

  /// Clear all user data
  Future<void> clearAllData() async {
    await _cacheBox.clear();
    await _userBox.clear();
    await _watchlistBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _cacheBox.close();
    await _userBox.close();
    await _watchlistBox.close();
  }
}
