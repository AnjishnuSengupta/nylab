/// Nylab - User Repository (Refactored)
///
/// Optional authentication matching nyanime.tech website behavior:
/// - Guest mode: Full streaming access, local history only
/// - Signed-in: Cloud sync for watchlist, history, and favorites
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

// ============================================================================
// TYPES
// ============================================================================

/// User authentication state
enum AuthState {
  guest, // Not signed in - local only, full streaming access
  signedIn, // Signed in - cloud sync enabled
  loading, // Auth state is being determined
}

/// Sync status for cloud operations
enum SyncStatus { synced, pending, syncing, error, offline }

/// Watch history entry (for API sync)
class WatchHistoryEntry {
  final int animeId;
  final String animeTitle;
  final String? animePoster;
  final int episodeNumber;
  final double progressPercent;
  final DateTime lastWatched;
  final bool isCompleted;

  WatchHistoryEntry({
    required this.animeId,
    required this.animeTitle,
    this.animePoster,
    required this.episodeNumber,
    this.progressPercent = 0.0,
    required this.lastWatched,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'animeTitle': animeTitle,
    'animePoster': animePoster,
    'episodeNumber': episodeNumber,
    'progressPercent': progressPercent,
    'lastWatched': lastWatched.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WatchHistoryEntry(
      animeId: json['animeId'] as int? ?? 0,
      animeTitle: json['animeTitle'] as String? ?? '',
      animePoster: json['animePoster'] as String?,
      episodeNumber: json['episodeNumber'] as int? ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      lastWatched: json['lastWatched'] != null
          ? DateTime.tryParse(json['lastWatched'] as String) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

/// User profile data
class UserProfile {
  final String? id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final bool isGuest;

  UserProfile({
    this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
    this.isGuest = true,
  });

  factory UserProfile.guest() => UserProfile(isGuest: true);

  factory UserProfile.fromFirebaseUser(User user) => UserProfile(
    id: user.uid,
    email: user.email,
    displayName: user.displayName,
    avatarUrl: user.photoURL,
    createdAt: user.metadata.creationTime,
    isGuest: user.isAnonymous,
  );
}

/// User stats
class UserStats {
  final int episodesWatched;
  final int animeCompleted;
  final int watchlistCount;
  final int totalWatchTime;
  final List<String> favoriteGenres;
  final int watchStreak;
  final double avgCompletion;

  UserStats({
    this.episodesWatched = 0,
    this.animeCompleted = 0,
    this.watchlistCount = 0,
    this.totalWatchTime = 0,
    this.favoriteGenres = const [],
    this.watchStreak = 0,
    this.avgCompletion = 0.0,
  });

  factory UserStats.empty() => UserStats();
}

// ============================================================================
// USER REPOSITORY INTERFACE
// ============================================================================

abstract class IUserRepository {
  // Auth
  Future<void> initialize();
  AuthState get authState;
  bool get isGuest;
  bool get isSignedIn;
  UserProfile get profile;

  // Auth actions (all optional - user can use app without signing in)
  Future<bool> signInWithEmail(String email, String password);
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );
  Future<bool> signInWithGoogle();
  Future<void> signOut();

  // Watch history (always works - local for guests, cloud for signed-in)
  Future<List<WatchHistoryEntry>> getWatchHistory();
  Future<void> updateWatchProgress(WatchHistoryEntry entry);
  Future<WatchHistoryEntry?> getLastWatched(int animeId);
  List<WatchHistoryEntry> getContinueWatching();

  // Watchlist (always works - local for guests, cloud for signed-in)
  List<WatchlistItem> getWatchlist();
  Future<void> addToWatchlist(WatchlistItem item);
  Future<void> removeFromWatchlist(int animeId);
  bool isInWatchlist(int animeId);

  // Stats
  UserStats getStats();

  // Sync (only for signed-in users)
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
  DateTime? get lastSyncTime;
  String get lastSyncedAgo;
  SyncStatus get syncStatus;

  // Storage
  void clearLocalData();
}

// ============================================================================
// OPTIONAL AUTH USER REPOSITORY
// ============================================================================

class OptionalAuthUserRepository implements IUserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  late Box<WatchlistItem> _watchlistBox;
  late Box<dynamic> _historyBox;
  late Box<dynamic> _settingsBox;
  bool _isInitialized = false;

  DateTime? _lastSyncTime;
  SyncStatus _syncStatus = SyncStatus.synced;
  AuthState _authState = AuthState.loading;
  UserProfile _profile = UserProfile.guest();

  OptionalAuthUserRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Open Hive boxes for local storage
    _watchlistBox = await Hive.openBox<WatchlistItem>('nylab_watchlist');
    _historyBox = await Hive.openBox('nylab_watch_history');
    _settingsBox = await Hive.openBox('nylab_user_settings');

    // Load last sync time
    final lastSyncStr = _settingsBox.get('last_sync_time') as String?;
    if (lastSyncStr != null) {
      _lastSyncTime = DateTime.tryParse(lastSyncStr);
    }

    // Check current auth state
    final user = _auth.currentUser;
    if (user != null) {
      _authState = AuthState.signedIn;
      _profile = UserProfile.fromFirebaseUser(user);
    } else {
      _authState = AuthState.guest;
      _profile = UserProfile.guest();
    }

    // Listen for auth changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _authState = AuthState.signedIn;
        _profile = UserProfile.fromFirebaseUser(user);
      } else {
        _authState = AuthState.guest;
        _profile = UserProfile.guest();
      }
    });

    _isInitialized = true;
  }

  @override
  AuthState get authState => _authState;

  @override
  bool get isGuest => _authState == AuthState.guest;

  @override
  bool get isSignedIn => _authState == AuthState.signedIn;

  @override
  UserProfile get profile => _profile;

  // ============ AUTH ACTIONS (ALL OPTIONAL) ============

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _profile = UserProfile.fromFirebaseUser(credential.user!);
        _authState = AuthState.signedIn;
        // Sync data from cloud after sign in
        await syncFromCloud();
        return true;
      }
      return false;
    } catch (e) {
      print('[UserRepository] signInWithEmail error: $e');
      return false;
    }
  }

  @override
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);

        // Create user document in Firestore
        await _createUserDocument(credential.user!, displayName);

        _profile = UserProfile.fromFirebaseUser(credential.user!);
        _authState = AuthState.signedIn;

        // Sync local data to cloud
        await syncToCloud();
        return true;
      }
      return false;
    } catch (e) {
      print('[UserRepository] signUpWithEmail error: $e');
      return false;
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(provider);
      if (credential.user != null) {
        // Create/update user document
        await _createUserDocument(
          credential.user!,
          credential.user!.displayName ?? 'User',
        );

        _profile = UserProfile.fromFirebaseUser(credential.user!);
        _authState = AuthState.signedIn;
        await syncFromCloud();
        return true;
      }
      return false;
    } catch (e) {
      print('[UserRepository] signInWithGoogle error: $e');
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _authState = AuthState.guest;
      _profile = UserProfile.guest();
    } catch (e) {
      print('[UserRepository] signOut error: $e');
    }
  }

  Future<void> _createUserDocument(User user, String displayName) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'id': user.uid,
        'email': user.email,
        'displayName': displayName,
        'avatar': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'watchlist': [],
        'favorites': [],
      });
    }
  }

  // ============ WATCH HISTORY (LOCAL + CLOUD) ============

  @override
  Future<List<WatchHistoryEntry>> getWatchHistory() async {
    await initialize();

    // If signed in, try to get from cloud first
    if (isSignedIn && _profile.id != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(_profile.id)
            .collection('history')
            .orderBy('lastWatched', descending: true)
            .limit(100)
            .get();

        final history = snapshot.docs.map((doc) {
          final data = doc.data();
          return WatchHistoryEntry(
            animeId: data['animeId'] as int? ?? 0,
            animeTitle: data['animeTitle'] as String? ?? '',
            animePoster: data['animePoster'] as String?,
            episodeNumber: data['episodeNumber'] as int? ?? 0,
            progressPercent:
                (data['progressPercent'] as num?)?.toDouble() ?? 0.0,
            lastWatched:
                (data['lastWatched'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isCompleted: data['isCompleted'] as bool? ?? false,
          );
        }).toList();

        // Cache locally
        for (final entry in history) {
          await _historyBox.put(
            '${entry.animeId}_${entry.episodeNumber}',
            entry.toJson(),
          );
        }

        return history;
      } catch (e) {
        print('[UserRepository] getWatchHistory cloud error: $e');
      }
    }

    // Return local history
    final localHistory = <WatchHistoryEntry>[];
    for (final key in _historyBox.keys) {
      final data = _historyBox.get(key);
      if (data is Map) {
        localHistory.add(
          WatchHistoryEntry.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    }
    localHistory.sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
    return localHistory;
  }

  @override
  Future<void> updateWatchProgress(WatchHistoryEntry entry) async {
    await initialize();

    // Always save locally
    await _historyBox.put(
      '${entry.animeId}_${entry.episodeNumber}',
      entry.toJson(),
    );

    // If signed in, also save to cloud
    if (isSignedIn && _profile.id != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_profile.id)
            .collection('history')
            .doc('${entry.animeId}_${entry.episodeNumber}')
            .set({
              'animeId': entry.animeId,
              'animeTitle': entry.animeTitle,
              'animePoster': entry.animePoster,
              'episodeNumber': entry.episodeNumber,
              'progressPercent': entry.progressPercent,
              'lastWatched': Timestamp.fromDate(entry.lastWatched),
              'isCompleted': entry.isCompleted,
            });
      } catch (e) {
        print('[UserRepository] updateWatchProgress cloud error: $e');
        _syncStatus = SyncStatus.pending;
      }
    }
  }

  @override
  Future<WatchHistoryEntry?> getLastWatched(int animeId) async {
    await initialize();

    // Search for latest episode watched for this anime
    WatchHistoryEntry? latest;
    for (final key in _historyBox.keys) {
      if (key.toString().startsWith('${animeId}_')) {
        final data = _historyBox.get(key);
        if (data is Map) {
          final entry = WatchHistoryEntry.fromJson(
            Map<String, dynamic>.from(data),
          );
          if (latest == null || entry.lastWatched.isAfter(latest.lastWatched)) {
            latest = entry;
          }
        }
      }
    }
    return latest;
  }

  @override
  List<WatchHistoryEntry> getContinueWatching() {
    if (!_isInitialized) return [];

    final seen = <int>{};
    final continueWatching = <WatchHistoryEntry>[];

    // Get unique anime entries, most recently watched
    final allEntries = <WatchHistoryEntry>[];
    for (final key in _historyBox.keys) {
      final data = _historyBox.get(key);
      if (data is Map) {
        allEntries.add(
          WatchHistoryEntry.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    }
    allEntries.sort((a, b) => b.lastWatched.compareTo(a.lastWatched));

    for (final entry in allEntries) {
      if (!seen.contains(entry.animeId) &&
          !entry.isCompleted &&
          entry.progressPercent < 0.9) {
        seen.add(entry.animeId);
        continueWatching.add(entry);
        if (continueWatching.length >= 10) break;
      }
    }

    return continueWatching;
  }

  // ============ WATCHLIST (LOCAL + CLOUD) ============

  @override
  List<WatchlistItem> getWatchlist() {
    if (!_isInitialized) return [];
    return _watchlistBox.values.toList();
  }

  @override
  Future<void> addToWatchlist(WatchlistItem item) async {
    await initialize();

    // Save locally
    await _watchlistBox.put(item.animeId.toString(), item);

    // If signed in, save to cloud
    if (isSignedIn && _profile.id != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_profile.id)
            .collection('watchlist')
            .doc(item.animeId.toString())
            .set({
              'animeId': item.animeId,
              'animeTitle': item.animeTitle,
              'animePosterUrl': item.animePosterUrl,
              'addedAt': Timestamp.fromDate(item.addedAt),
              'status': item.status.name,
              'episodesWatched': item.episodesWatched,
              'totalEpisodes': item.totalEpisodes,
            });
      } catch (e) {
        print('[UserRepository] addToWatchlist cloud error: $e');
        _syncStatus = SyncStatus.pending;
      }
    }
  }

  @override
  Future<void> removeFromWatchlist(int animeId) async {
    await initialize();

    // Remove locally
    await _watchlistBox.delete(animeId.toString());

    // If signed in, remove from cloud
    if (isSignedIn && _profile.id != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_profile.id)
            .collection('watchlist')
            .doc(animeId.toString())
            .delete();
      } catch (e) {
        print('[UserRepository] removeFromWatchlist cloud error: $e');
      }
    }
  }

  @override
  bool isInWatchlist(int animeId) {
    if (!_isInitialized) return false;
    return _watchlistBox.containsKey(animeId.toString());
  }

  // ============ STATS ============

  @override
  UserStats getStats() {
    if (!_isInitialized) return UserStats.empty();

    int episodesWatched = 0;
    int animeCompleted = 0;
    final genreCounts = <String, int>{};
    double totalProgress = 0;
    int progressCount = 0;

    for (final key in _historyBox.keys) {
      final data = _historyBox.get(key);
      if (data is Map) {
        episodesWatched++;
        final entry = WatchHistoryEntry.fromJson(
          Map<String, dynamic>.from(data),
        );
        totalProgress += entry.progressPercent;
        progressCount++;
        if (entry.isCompleted) animeCompleted++;
      }
    }

    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(5).map((e) => e.key).toList();

    return UserStats(
      episodesWatched: episodesWatched,
      animeCompleted: animeCompleted,
      watchlistCount: _watchlistBox.length,
      totalWatchTime: episodesWatched * 24, // Assume 24 min per episode
      favoriteGenres: topGenres,
      avgCompletion: progressCount > 0 ? totalProgress / progressCount : 0.0,
    );
  }

  // ============ SYNC (SIGNED-IN ONLY) ============

  @override
  Future<void> syncToCloud() async {
    if (!isSignedIn || _profile.id == null) return;

    try {
      _syncStatus = SyncStatus.syncing;

      // Sync watchlist
      final batch = _firestore.batch();
      for (final item in _watchlistBox.values) {
        final docRef = _firestore
            .collection('users')
            .doc(_profile.id)
            .collection('watchlist')
            .doc(item.animeId.toString());
        batch.set(docRef, {
          'animeId': item.animeId,
          'animeTitle': item.animeTitle,
          'animePosterUrl': item.animePosterUrl,
          'addedAt': Timestamp.fromDate(item.addedAt),
          'status': item.status.name,
          'episodesWatched': item.episodesWatched,
          'totalEpisodes': item.totalEpisodes,
        });
      }

      // Sync history
      for (final key in _historyBox.keys) {
        final data = _historyBox.get(key);
        if (data is Map) {
          final entry = WatchHistoryEntry.fromJson(
            Map<String, dynamic>.from(data),
          );
          final docRef = _firestore
              .collection('users')
              .doc(_profile.id)
              .collection('history')
              .doc(key.toString());
          batch.set(docRef, {
            'animeId': entry.animeId,
            'animeTitle': entry.animeTitle,
            'animePoster': entry.animePoster,
            'episodeNumber': entry.episodeNumber,
            'progressPercent': entry.progressPercent,
            'lastWatched': Timestamp.fromDate(entry.lastWatched),
            'isCompleted': entry.isCompleted,
          });
        }
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
    if (!isSignedIn || _profile.id == null) return;

    try {
      _syncStatus = SyncStatus.syncing;

      // Sync watchlist from cloud
      final watchlistSnapshot = await _firestore
          .collection('users')
          .doc(_profile.id)
          .collection('watchlist')
          .get();

      for (final doc in watchlistSnapshot.docs) {
        final data = doc.data();
        final item = WatchlistItem(
          animeId: data['animeId'] as int? ?? 0,
          animeTitle: data['animeTitle'] as String? ?? '',
          animePosterUrl: data['animePosterUrl'] as String? ?? '',
          addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: WatchlistStatus.values.firstWhere(
            (s) => s.name == (data['status'] as String? ?? 'planToWatch'),
            orElse: () => WatchlistStatus.planToWatch,
          ),
          episodesWatched: data['episodesWatched'] as int? ?? 0,
          totalEpisodes: data['totalEpisodes'] as int?,
        );
        await _watchlistBox.put(item.animeId.toString(), item);
      }

      // Sync history from cloud
      final historySnapshot = await _firestore
          .collection('users')
          .doc(_profile.id)
          .collection('history')
          .get();

      for (final doc in historySnapshot.docs) {
        final data = doc.data();
        final entry = WatchHistoryEntry(
          animeId: data['animeId'] as int? ?? 0,
          animeTitle: data['animeTitle'] as String? ?? '',
          animePoster: data['animePoster'] as String?,
          episodeNumber: data['episodeNumber'] as int? ?? 0,
          progressPercent: (data['progressPercent'] as num?)?.toDouble() ?? 0.0,
          lastWatched:
              (data['lastWatched'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isCompleted: data['isCompleted'] as bool? ?? false,
        );
        await _historyBox.put(
          '${entry.animeId}_${entry.episodeNumber}',
          entry.toJson(),
        );
      }

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
  DateTime? get lastSyncTime => _lastSyncTime;

  @override
  String get lastSyncedAgo {
    if (_lastSyncTime == null) return 'Never synced';
    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  SyncStatus get syncStatus => _syncStatus;

  @override
  void clearLocalData() {
    if (_isInitialized) {
      _watchlistBox.clear();
      _historyBox.clear();
      _settingsBox.clear();
    }
  }
}

// ============================================================================
// SINGLETON INSTANCE
// ============================================================================

final userRepository = OptionalAuthUserRepository();
