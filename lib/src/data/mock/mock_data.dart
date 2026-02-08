/// NYAnime Mobile - Mock Data
///
/// Realistic mock data for development and testing.
/// TODO: Replace with real https://www.nyanime.tech API calls
library;

import '../models/models.dart';

class MockData {
  MockData._();

  // Sample HLS video URLs for testing (public test streams)
  static const List<String> sampleHlsUrls = [
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
    'https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8',
  ];

  // High-quality anime poster URLs (placeholder images)
  static const List<String> posterUrls = [
    'https://cdn.myanimelist.net/images/anime/1286/99889l.jpg', // Jujutsu Kaisen
    'https://cdn.myanimelist.net/images/anime/6/73245l.jpg', // One Piece
    'https://cdn.myanimelist.net/images/anime/1171/109222l.jpg', // Spy x Family
    'https://cdn.myanimelist.net/images/anime/1015/138006l.jpg', // Demon Slayer
    'https://cdn.myanimelist.net/images/anime/1208/94745l.jpg', // Attack on Titan
    'https://cdn.myanimelist.net/images/anime/10/78745l.jpg', // My Hero Academia
    'https://cdn.myanimelist.net/images/anime/1935/127974l.jpg', // Chainsaw Man
    'https://cdn.myanimelist.net/images/anime/1498/134443l.jpg', // Frieren
    'https://cdn.myanimelist.net/images/anime/1160/122627l.jpg', // Bocchi the Rock
    'https://cdn.myanimelist.net/images/anime/1244/138851l.jpg', // Solo Leveling
  ];

  /// Get trending anime list
  static List<Anime> getTrendingAnime() {
    return [
      Anime(
        id: 1,
        title: 'Jujutsu Kaisen',
        titleEnglish: 'Jujutsu Kaisen',
        titleJapanese: '呪術廻戦',
        synopsis:
            'Idly indulging in baseless paranormal activities with the Occult Club, high schooler Yuuji Itadori spends his days at either the clubroom or the hospital, where he visits his bedridden grandfather. However, this leisurely lifestyle soon takes a turn for the strange when he unknowingly encounters a cursed item.',
        posterUrl: posterUrls[0],
        bannerUrl: posterUrls[0],
        score: 8.67,
        scoredBy: 1500000,
        rank: 52,
        popularity: 6,
        members: 2800000,
        favorites: 125000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: 24,
        duration: '24 min per ep',
        rating: 'R - 17+ (violence & profanity)',
        season: 'Fall',
        year: 2025,
        airedFrom: DateTime(2025, 10, 3),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(days: 3, hours: 12, minutes: 45),
        ),
        nextEpisodeNumber: 15,
        genres: ['Action', 'Fantasy', 'School', 'Shounen'],
        themes: ['Gore', 'Mythology', 'Super Power'],
        studios: ['MAPPA'],
        producers: ['TOHO animation', 'Shueisha'],
        source: 'Manga',
        isAiring: true,
      ),
      Anime(
        id: 2,
        title: 'One Piece',
        titleEnglish: 'One Piece',
        titleJapanese: 'ONE PIECE',
        synopsis:
            'Gol D. Roger was known as the "Pirate King," the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his death revealed the existence of the greatest treasure in the world, One Piece.',
        posterUrl: posterUrls[1],
        bannerUrl: posterUrls[1],
        score: 8.71,
        scoredBy: 1200000,
        rank: 45,
        popularity: 11,
        members: 2200000,
        favorites: 200000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: null,
        duration: '24 min per ep',
        rating: 'PG-13 - Teens 13 or older',
        season: 'Fall',
        year: 1999,
        airedFrom: DateTime(1999, 10, 20),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(days: 5, hours: 8, minutes: 30),
        ),
        nextEpisodeNumber: 1125,
        genres: ['Action', 'Adventure', 'Fantasy'],
        themes: ['Gourmet', 'Pirate', 'Super Power'],
        studios: ['Toei Animation'],
        producers: ['Fuji TV', 'TAP', 'Shueisha'],
        source: 'Manga',
        isAiring: true,
      ),
      Anime(
        id: 3,
        title: 'Spy x Family',
        titleEnglish: 'SPY×FAMILY',
        titleJapanese: 'SPY×FAMILY',
        synopsis:
            'Twilight, the greatest spy for the nation of Westalis, has to infiltrate an elite private school. To do so, he assumes the identity of psychiatrist Loid Forger and starts building a cover family, adopting an orphan girl named Anya and marrying an assassin named Yor.',
        posterUrl: posterUrls[2],
        bannerUrl: posterUrls[2],
        score: 8.57,
        scoredBy: 980000,
        rank: 78,
        popularity: 8,
        members: 1800000,
        favorites: 89000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: 25,
        duration: '24 min per ep',
        rating: 'PG-13 - Teens 13 or older',
        season: 'Spring',
        year: 2025,
        airedFrom: DateTime(2025, 4, 9),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(days: 1, hours: 18, minutes: 15),
        ),
        nextEpisodeNumber: 8,
        genres: ['Action', 'Comedy', 'Slice of Life'],
        themes: ['Childcare', 'Parody'],
        studios: ['Wit Studio', 'CloverWorks'],
        producers: ['TOHO animation', 'Shueisha'],
        source: 'Manga',
        isAiring: true,
      ),
      Anime(
        id: 4,
        title: 'Kimetsu no Yaiba',
        titleEnglish: 'Demon Slayer: Kimetsu no Yaiba',
        titleJapanese: '鬼滅の刃',
        synopsis:
            'Ever since the death of his father, the burden of supporting the family has fallen upon Tanjirou Kamado\'s shoulders. Though living impoverished on a remote mountain, the Kamado family are able to enjoy a relatively peaceful and happy life.',
        posterUrl: posterUrls[3],
        bannerUrl: posterUrls[3],
        score: 8.52,
        scoredBy: 2100000,
        rank: 92,
        popularity: 3,
        members: 3500000,
        favorites: 170000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: 11,
        duration: '24 min per ep',
        rating: 'R - 17+ (violence & profanity)',
        season: 'Spring',
        year: 2025,
        airedFrom: DateTime(2025, 4, 6),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(days: 4, hours: 6, minutes: 0),
        ),
        nextEpisodeNumber: 6,
        genres: ['Action', 'Fantasy', 'Shounen'],
        themes: ['Historical', 'Demons', 'Gore'],
        studios: ['ufotable'],
        producers: ['Aniplex', 'Shueisha'],
        source: 'Manga',
        isAiring: true,
      ),
      Anime(
        id: 5,
        title: 'Shingeki no Kyojin: The Final Season',
        titleEnglish: 'Attack on Titan: The Final Season',
        titleJapanese: '進撃の巨人 The Final Season',
        synopsis:
            'Gabi Braun and Falco Grice have been training their entire lives to inherit one of the seven Titans under Marley\'s control and help their nation destroy the enemy forces on Paradis. However, just as their training draws to a close, the world witnesses a turn in the war.',
        posterUrl: posterUrls[4],
        bannerUrl: posterUrls[4],
        score: 9.05,
        scoredBy: 1800000,
        rank: 8,
        popularity: 1,
        members: 4200000,
        favorites: 250000,
        status: 'Finished Airing',
        type: 'TV',
        episodeCount: 16,
        duration: '24 min per ep',
        rating: 'R - 17+ (violence & profanity)',
        season: 'Winter',
        year: 2024,
        airedFrom: DateTime(2024, 1, 7),
        airedTo: DateTime(2024, 4, 14),
        nextEpisodeAt: null,
        nextEpisodeNumber: null,
        genres: ['Action', 'Drama', 'Suspense'],
        themes: ['Gore', 'Military', 'Survival'],
        studios: ['MAPPA'],
        producers: ['Production I.G', 'Wit Studio'],
        source: 'Manga',
        isAiring: false,
      ),
    ];
  }

  /// Get seasonal anime
  static List<Anime> getSeasonalAnime() {
    return [
      Anime(
        id: 6,
        title: 'Boku no Hero Academia',
        titleEnglish: 'My Hero Academia',
        titleJapanese: '僕のヒーローアカデミア',
        synopsis:
            'The appearance of "quirks," newly discovered super powers, has been steadily increasing over the years, with 80 percent of humanity possessing various abilities from manipulation of elements to shapeshifting.',
        posterUrl: posterUrls[5],
        bannerUrl: posterUrls[5],
        score: 8.12,
        scoredBy: 900000,
        rank: 187,
        popularity: 4,
        members: 3100000,
        favorites: 110000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: 25,
        duration: '24 min per ep',
        rating: 'PG-13 - Teens 13 or older',
        season: 'Spring',
        year: 2025,
        airedFrom: DateTime(2025, 4, 5),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(days: 2, hours: 9, minutes: 30),
        ),
        nextEpisodeNumber: 12,
        genres: ['Action', 'Comedy', 'School', 'Shounen'],
        themes: ['Super Power'],
        studios: ['Bones'],
        producers: ['Yomiuri Telecasting', 'Shueisha'],
        source: 'Manga',
        isAiring: true,
      ),
      Anime(
        id: 7,
        title: 'Chainsaw Man',
        titleEnglish: 'Chainsaw Man',
        titleJapanese: 'チェンソーマン',
        synopsis:
            'Denji has a simple dream—to live a happy and peaceful life, spending time with a girl he likes. This is a far cry from reality, however, as Denji is forced by the yakuza into killing devils in order to pay off his crushing debts.',
        posterUrl: posterUrls[6],
        bannerUrl: posterUrls[6],
        score: 8.55,
        scoredBy: 1100000,
        rank: 85,
        popularity: 7,
        members: 2600000,
        favorites: 130000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: 12,
        duration: '24 min per ep',
        rating: 'R - 17+ (violence & profanity)',
        season: 'Fall',
        year: 2025,
        airedFrom: DateTime(2025, 10, 11),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(days: 6, hours: 14, minutes: 0),
        ),
        nextEpisodeNumber: 3,
        genres: ['Action', 'Fantasy', 'Shounen'],
        themes: ['Gore', 'Survival'],
        studios: ['MAPPA'],
        producers: ['TOHO animation', 'Shueisha'],
        source: 'Manga',
        isAiring: true,
      ),
      Anime(
        id: 8,
        title: 'Sousou no Frieren',
        titleEnglish: 'Frieren: Beyond Journey\'s End',
        titleJapanese: '葬送のフリーレン',
        synopsis:
            'After the party of heroes defeated the Demon King, they restored peace to the land and returned to lives of solitude. Elf mage Frieren comes to terms with the death of her friends one by one and embarks on a journey to find the secret to immortality.',
        posterUrl: posterUrls[7],
        bannerUrl: posterUrls[7],
        score: 9.33,
        scoredBy: 700000,
        rank: 1,
        popularity: 15,
        members: 1500000,
        favorites: 95000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: 28,
        duration: '24 min per ep',
        rating: 'PG-13 - Teens 13 or older',
        season: 'Fall',
        year: 2025,
        airedFrom: DateTime(2025, 9, 29),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(hours: 22, minutes: 30),
        ),
        nextEpisodeNumber: 10,
        genres: ['Adventure', 'Drama', 'Fantasy'],
        themes: ['Isekai', 'Magic'],
        studios: ['Madhouse'],
        producers: ['Aniplex', 'Shogakukan'],
        source: 'Manga',
        isAiring: true,
      ),
      Anime(
        id: 9,
        title: 'Bocchi the Rock!',
        titleEnglish: 'Bocchi the Rock!',
        titleJapanese: 'ぼっち・ざ・ろっく！',
        synopsis:
            'Hitori Gotou, an introverted and socially anxious girl, is a guitar player. Her dream is to be in a band, but she is afraid of interacting with others. One day, a drummer named Nijika Ijichi invites her to join her band.',
        posterUrl: posterUrls[8],
        bannerUrl: posterUrls[8],
        score: 8.87,
        scoredBy: 500000,
        rank: 28,
        popularity: 42,
        members: 900000,
        favorites: 75000,
        status: 'Finished Airing',
        type: 'TV',
        episodeCount: 12,
        duration: '24 min per ep',
        rating: 'PG-13 - Teens 13 or older',
        season: 'Fall',
        year: 2024,
        airedFrom: DateTime(2024, 10, 8),
        airedTo: DateTime(2024, 12, 24),
        nextEpisodeAt: null,
        nextEpisodeNumber: null,
        genres: ['Comedy', 'Slice of Life'],
        themes: ['CGDCT', 'Music', 'School'],
        studios: ['CloverWorks'],
        producers: ['Aniplex', 'Houbunsha'],
        source: 'Manga',
        isAiring: false,
      ),
      Anime(
        id: 10,
        title: 'Solo Leveling',
        titleEnglish: 'Solo Leveling',
        titleJapanese: '俺だけレベルアップな件',
        synopsis:
            'Ten years ago, "the Gate" appeared and connected the real world with the realm of magic and monsters. To combat these vile beasts, ordinary people received supernatural powers and became known as "Hunters."',
        posterUrl: posterUrls[9],
        bannerUrl: posterUrls[9],
        score: 8.62,
        scoredBy: 600000,
        rank: 65,
        popularity: 22,
        members: 1300000,
        favorites: 85000,
        status: 'Currently Airing',
        type: 'TV',
        episodeCount: 12,
        duration: '24 min per ep',
        rating: 'R - 17+ (violence & profanity)',
        season: 'Winter',
        year: 2025,
        airedFrom: DateTime(2025, 1, 6),
        airedTo: null,
        nextEpisodeAt: DateTime.now().add(
          const Duration(days: 2, hours: 4, minutes: 15),
        ),
        nextEpisodeNumber: 8,
        genres: ['Action', 'Adventure', 'Fantasy'],
        themes: ['Isekai', 'Video Game'],
        studios: ['A-1 Pictures'],
        producers: ['Aniplex', 'Crunchyroll'],
        source: 'Web Novel',
        isAiring: true,
      ),
    ];
  }

  /// Get episodes for an anime
  static List<Episode> getEpisodes(int animeId, {int count = 24}) {
    final anime = [...getTrendingAnime(), ...getSeasonalAnime()].firstWhere(
      (a) => a.id == animeId,
      orElse: () => getTrendingAnime().first,
    );

    return List.generate(count, (index) {
      final episodeNum = index + 1;
      return Episode(
        id: animeId * 1000 + episodeNum,
        animeId: animeId,
        number: episodeNum,
        title: _getEpisodeTitle(animeId, episodeNum),
        titleJapanese: '第$episodeNum話',
        synopsis:
            'In this thrilling episode, our heroes face new challenges and discover hidden truths about their world. Action-packed sequences and emotional moments await!',
        thumbnailUrl: anime.posterUrl,
        streamUrl: sampleHlsUrls[index % sampleHlsUrls.length],
        duration: Duration(minutes: 23 + (index % 3)),
        airedAt: DateTime.now().subtract(Duration(days: (count - index) * 7)),
        isFiller: index == 5 || index == 12,
        isRecap: index == 11,
        score: 4.0 + (index % 10) / 10,
      );
    });
  }

  /// Get episode titles based on anime
  static String _getEpisodeTitle(int animeId, int episodeNum) {
    final titles = {
      1: [
        'Ryomen Sukuna',
        'For Myself',
        'Girl of Steel',
        'Curse Womb Must Die',
        'Fearsome Womb',
        'After Rain',
        'Assault',
      ],
      2: [
        'Romance Dawn',
        'Enter the Great Swordsman',
        'Morgan vs. Luffy',
        'Buggy the Clown',
        'Fear, Mysterious Power!',
      ],
      3: [
        'Operation Strix',
        'Secure a Wife',
        'Prepare for the Interview',
        'The Prestigious School\'s Interview',
      ],
      4: [
        'Cruelty',
        'Trainer Sakonji Urokodaki',
        'Sabito and Makomo',
        'Final Selection',
        'My Own Steel',
      ],
      5: [
        'The Other Side of the Sea',
        'Midnight Train',
        'The Door of Hope',
        'From One Hand to Another',
      ],
    };

    final animeTitles =
        titles[animeId] ??
        ['The Beginning', 'A New Challenge', 'Hidden Truth', 'Turning Point'];
    return animeTitles[episodeNum % animeTitles.length];
  }

  /// Get continue watching list
  static List<WatchProgress> getContinueWatching() {
    return [
      WatchProgress(
        animeId: 1,
        episodeId: 1014,
        episodeNumber: 14,
        watchedDuration: const Duration(minutes: 15, seconds: 32),
        totalDuration: const Duration(minutes: 24, seconds: 0),
        lastWatchedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isCompleted: false,
      ),
      WatchProgress(
        animeId: 3,
        episodeId: 3007,
        episodeNumber: 7,
        watchedDuration: const Duration(minutes: 8, seconds: 45),
        totalDuration: const Duration(minutes: 24, seconds: 0),
        lastWatchedAt: DateTime.now().subtract(const Duration(hours: 5)),
        isCompleted: false,
      ),
      WatchProgress(
        animeId: 8,
        episodeId: 8009,
        episodeNumber: 9,
        watchedDuration: const Duration(minutes: 20, seconds: 12),
        totalDuration: const Duration(minutes: 24, seconds: 0),
        lastWatchedAt: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: false,
      ),
      WatchProgress(
        animeId: 10,
        episodeId: 10007,
        episodeNumber: 7,
        watchedDuration: const Duration(minutes: 22, seconds: 0),
        totalDuration: const Duration(minutes: 24, seconds: 0),
        lastWatchedAt: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
      ),
    ];
  }

  /// Get watchlist
  static List<WatchlistItem> getWatchlist() {
    final trending = getTrendingAnime();
    final seasonal = getSeasonalAnime();
    return [
      WatchlistItem(
        animeId: 1,
        animeTitle: trending[0].displayTitle,
        animePosterUrl: trending[0].posterUrl,
        addedAt: DateTime.now().subtract(const Duration(days: 30)),
        status: WatchlistStatus.watching,
        userScore: 9,
        episodesWatched: 14,
        totalEpisodes: 24,
      ),
      WatchlistItem(
        animeId: 2,
        animeTitle: trending[1].displayTitle,
        animePosterUrl: trending[1].posterUrl,
        addedAt: DateTime.now().subtract(const Duration(days: 180)),
        status: WatchlistStatus.watching,
        userScore: 10,
        episodesWatched: 1124,
        totalEpisodes: null,
      ),
      WatchlistItem(
        animeId: 5,
        animeTitle: trending[4].displayTitle,
        animePosterUrl: trending[4].posterUrl,
        addedAt: DateTime.now().subtract(const Duration(days: 365)),
        status: WatchlistStatus.completed,
        userScore: 10,
        episodesWatched: 16,
        totalEpisodes: 16,
      ),
      WatchlistItem(
        animeId: 8,
        animeTitle: seasonal[2].displayTitle,
        animePosterUrl: seasonal[2].posterUrl,
        addedAt: DateTime.now().subtract(const Duration(days: 14)),
        status: WatchlistStatus.watching,
        userScore: 10,
        episodesWatched: 9,
        totalEpisodes: 28,
      ),
      WatchlistItem(
        animeId: 10,
        animeTitle: seasonal[4].displayTitle,
        animePosterUrl: seasonal[4].posterUrl,
        addedAt: DateTime.now().subtract(const Duration(days: 7)),
        status: WatchlistStatus.watching,
        userScore: 8,
        episodesWatched: 7,
        totalEpisodes: 12,
      ),
    ];
  }

  /// Get mock user stats
  static UserStats getUserStats() {
    return UserStats(
      totalEpisodesWatched: 1287,
      totalAnimeCompleted: 54,
      totalWatchTimeMinutes: 30888, // ~514 hours
      currentStreak: 7,
      longestStreak: 32,
      genreDistribution: {
        'Action': 425,
        'Comedy': 287,
        'Drama': 198,
        'Fantasy': 312,
        'Romance': 156,
        'Slice of Life': 134,
        'Supernatural': 89,
        'Sci-Fi': 76,
      },
      favoriteStudios: ['MAPPA', 'ufotable', 'Wit Studio', 'Bones', 'Madhouse'],
      averageScore: 8.2,
      scoreDistribution: {
        10: 12,
        9: 28,
        8: 67,
        7: 89,
        6: 45,
        5: 23,
        4: 8,
        3: 3,
        2: 1,
        1: 0,
      },
    );
  }

  /// Get genres list
  static List<String> getGenres() {
    return [
      'Action',
      'Adventure',
      'Comedy',
      'Drama',
      'Fantasy',
      'Horror',
      'Isekai',
      'Mecha',
      'Music',
      'Mystery',
      'Psychological',
      'Romance',
      'Sci-Fi',
      'Slice of Life',
      'Sports',
      'Supernatural',
      'Thriller',
    ];
  }

  /// Search anime by query
  static List<Anime> searchAnime(String query) {
    final allAnime = [...getTrendingAnime(), ...getSeasonalAnime()];
    if (query.isEmpty) return allAnime;

    final lowerQuery = query.toLowerCase();
    return allAnime.where((anime) {
      return anime.title.toLowerCase().contains(lowerQuery) ||
          (anime.titleEnglish?.toLowerCase().contains(lowerQuery) ?? false) ||
          anime.genres.any((g) => g.toLowerCase().contains(lowerQuery)) ||
          anime.studios.any((s) => s.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get anime by ID
  static Anime? getAnimeById(int id) {
    final allAnime = [...getTrendingAnime(), ...getSeasonalAnime()];
    try {
      return allAnime.firstWhere((anime) => anime.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get episodes for anime
  static List<Episode> getEpisodesForAnime(int animeId) {
    return getEpisodes(animeId, count: 12);
  }

  /// Get specific episode by ID
  static Episode? getEpisodeById(int animeId, int episodeId) {
    final episodes = getEpisodesForAnime(animeId);
    try {
      return episodes.firstWhere((e) => e.id == episodeId);
    } catch (e) {
      return episodes.isNotEmpty ? episodes.first : null;
    }
  }
}
