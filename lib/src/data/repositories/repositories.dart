/// Nylab - Repositories Barrel Export
///
/// Exports all repository implementations for easy imports.
library;

export 'anime_repository.dart';
export 'jikan_anime_repository.dart' hide IAnimeRepository, animeRepository;
export 'stream_repository.dart';
export 'user_repository.dart';
export 'optional_auth_user_repository.dart'
    hide
        SyncStatus,
        UserProfile,
        UserStats,
        WatchHistoryEntry,
        IUserRepository,
        userRepository;
