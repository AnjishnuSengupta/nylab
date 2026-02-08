/// Nylab - User Repository (Domain Layer)
///
/// Repository for user data, watchlist, and watch progress with Firebase sync.
library;

import '../../data/data.dart';
import '../../data/repositories/user_repository.dart' as impl;

class UserRepository {
  final LocalStorage _localStorage;
  final impl.FirebaseUserRepository _firebaseRepo;
  bool _isInitialized = false;

  UserRepository({
    required LocalStorage localStorage,
    impl.FirebaseUserRepository? firebaseRepo,
  }) : _localStorage = localStorage,
       _firebaseRepo = firebaseRepo ?? impl.userRepository;

  /// Initialize the repository
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _firebaseRepo.initialize();
    _isInitialized = true;
  }

  /// Sign in anonymously with Firebase
  Future<String?> signInAnonymously() async {
    await initialize();
    return _firebaseRepo.signInAnonymously();
  }

  /// Check if user is signed in
  bool get isSignedIn => _firebaseRepo.isSignedIn;

  /// Get current user ID
  String? get userId => _firebaseRepo.userId;

  /// Get last sync time
  DateTime? get lastSyncTime => _firebaseRepo.lastSyncTime;

  /// Get formatted "last synced" string
  String get lastSyncedAgo => _firebaseRepo.lastSyncedAgo;

  /// Get sync status
  impl.SyncStatus get syncStatus => _firebaseRepo.syncStatus;

  // ============ Watch Progress ============

  /// Save watch progress (local + cloud sync)
  Future<void> saveWatchProgress(WatchProgress progress) async {
    // Save locally first
    await _localStorage.saveWatchProgress(progress);

    // Sync to cloud if signed in
    await initialize();
    final slug = progress.animeId.toString(); // In real app, lookup slug
    await _firebaseRepo.updateWatchProgress(
      impl.WatchHistoryEntry(
        animeId: progress.animeId.toString(),
        animeSlug: slug,
        animeTitle: 'Anime', // Would need to look this up
        episodeNumber: progress.episodeNumber,
        watchedAt: progress.lastWatchedAt,
        progressPercent: progress.progressPercent,
        isCompleted: progress.isCompleted,
      ),
    );
  }

  /// Get watch progress for an episode
  WatchProgress? getWatchProgress(int animeId, int episodeId) {
    return _localStorage.getWatchProgress(animeId, episodeId);
  }

  /// Get continue watching list (local)
  List<WatchProgress> getContinueWatching() {
    return _localStorage.getContinueWatching();
  }

  /// Get continue watching from cloud
  Future<List<impl.WatchHistoryEntry>> getContinueWatchingCloud() async {
    await initialize();
    return _firebaseRepo.getContinueWatching();
  }

  // ============ Watchlist ============

  /// Add anime to watchlist (with cloud sync)
  Future<void> addToWatchlist(WatchlistItem item) async {
    await _localStorage.addToWatchlist(item);
    await initialize();
    await _firebaseRepo.toggleWatchlist(item);
  }

  /// Remove anime from watchlist (with cloud sync)
  Future<void> removeFromWatchlist(int animeId) async {
    await _localStorage.removeFromWatchlist(animeId);
    // Cloud removal is handled by toggleWatchlist
  }

  /// Get watchlist item
  WatchlistItem? getWatchlistItem(int animeId) {
    return _localStorage.getWatchlistItem(animeId);
  }

  /// Get all watchlist items (local)
  List<WatchlistItem> getWatchlist({WatchlistStatus? status}) {
    return _localStorage.getWatchlist(status: status);
  }

  /// Get watchlist from cloud
  Future<List<WatchlistItem>> getWatchlistCloud() async {
    await initialize();
    return _firebaseRepo.getWatchlist();
  }

  /// Check if anime is in watchlist
  bool isInWatchlist(int animeId) {
    return _localStorage.isInWatchlist(animeId);
  }

  /// Update watchlist item
  Future<void> updateWatchlistItem(WatchlistItem item) async {
    await _localStorage.updateWatchlistItem(item);
  }

  // ============ Cloud Sync ============

  /// Sync data to cloud
  Future<void> syncToCloud() async {
    await initialize();
    await _firebaseRepo.syncToCloud();
  }

  /// Sync data from cloud
  Future<void> syncFromCloud() async {
    await initialize();
    await _firebaseRepo.syncFromCloud();
  }

  // ============ User Stats ============

  /// Get user stats
  UserStats getUserStats() {
    return MockData.getUserStats();
  }

  /// Get user profile
  UserProfile getUserProfile() {
    return UserProfile.empty().copyWith(stats: getUserStats());
  }

  // ============ Settings ============

  /// Check if onboarding completed
  bool isOnboardingCompleted() {
    return _localStorage.isOnboardingCompleted();
  }

  /// Set onboarding completed
  Future<void> setOnboardingCompleted() async {
    await _localStorage.setOnboardingCompleted();
  }

  /// Get playback speed
  double getPlaybackSpeed() {
    return _localStorage.getPlaybackSpeed();
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    await _localStorage.setPlaybackSpeed(speed);
  }

  /// Clear all local data
  Future<void> clearAllData() async {
    await _localStorage.clearAllData();
    _firebaseRepo.clearLocalData();
  }
}
