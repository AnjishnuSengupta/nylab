/// NYAnime Mobile - Search Screen
///
/// Search screen with debounced input, genre filters, and results grid.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> _genres = [
    'All',
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Supernatural',
    'Thriller',
  ];

  String _selectedGenre = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              _buildSearchHeader(),

              // Genre Chips
              _buildGenreChips(),

              // Results or Suggestions
              Expanded(
                child: isSearching
                    ? _buildSearchResults(searchResults)
                    : _buildSearchSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          // Search field
          GlassmorphismCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            borderRadius: AppConstants.borderRadiusFull,
            backgroundColor: AppColors.cardBackground.withOpacity(0.8),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search anime, manga, characters...',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      ref.read(searchQueryProvider.notifier).state = value;
                      setState(() {});
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final genre = _genres[index];
          final isSelected = _selectedGenre == genre;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedGenre = genre;
                });
              },
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusFull,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  genre,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Anime>> searchResults) {
    return searchResults.when(
      data: (animeList) {
        if (animeList.isEmpty) {
          return _buildEmptyResults();
        }

        // Filter by selected genre
        final filteredList = _selectedGenre == 'All'
            ? animeList
            : animeList
                  .where((a) => a.genres.contains(_selectedGenre))
                  .toList();

        if (filteredList.isEmpty) {
          return _buildEmptyResults();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.gridColumns(context),
            childAspectRatio: 0.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final anime = filteredList[index];
            return AnimeCard(
              anime: anime,
              heroTag: 'search_${anime.id}',
              onTap: () {
                context.push('/anime/${anime.id}');
              },
            );
          },
        );
      },
      loading: () => const ShimmerGrid(itemCount: 6),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.accentRed,
            ),
            const SizedBox(height: 16),
            Text('Search failed', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term\nor filter',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final recentSearches = ['Jujutsu Kaisen', 'One Piece', 'Chainsaw Man'];
    final trendingSearches = [
      'Solo Leveling',
      'Frieren',
      'Spy x Family',
      'Demon Slayer',
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Recent searches
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🕐 Recent Searches',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // TODO: Clear recent searches
                },
                child: Text(
                  'Clear',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return _buildSuggestionChip(search, isRecent: true);
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],

        // Trending searches
        Text(
          '🔥 Trending Searches',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trendingSearches.map((search) {
            return _buildSuggestionChip(search);
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Browse by genre
        Text(
          '📚 Browse by Genre',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildGenreGrid(),
      ],
    );
  }

  Widget _buildSuggestionChip(String text, {bool isRecent = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _searchController.text = text;
        ref.read(searchQueryProvider.notifier).state = text;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusFull),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecent) ...[
              const Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreGrid() {
    final genreData = [
      ('Action', Icons.bolt_rounded, AppColors.genreAction),
      ('Adventure', Icons.explore_rounded, AppColors.genreAdventure),
      ('Comedy', Icons.sentiment_very_satisfied_rounded, AppColors.genreComedy),
      ('Drama', Icons.theater_comedy_rounded, AppColors.genreDrama),
      ('Fantasy', Icons.auto_awesome_rounded, AppColors.genreFantasy),
      ('Romance', Icons.favorite_rounded, AppColors.genreRomance),
      ('Horror', Icons.nightlight_rounded, AppColors.genreHorror),
      ('Sci-Fi', Icons.rocket_launch_rounded, AppColors.genreSciFi),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: genreData.length,
      itemBuilder: (context, index) {
        final (genre, icon, color) = genreData[index];
        return _buildGenreCard(genre, icon, color);
      },
    );
  }

  Widget _buildGenreCard(String genre, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedGenre = genre;
        });
        // Trigger search with genre
        ref.read(searchQueryProvider.notifier).state = genre;
        _searchController.text = '';
        _searchFocusNode.unfocus();
      },
      child: GlassmorphismCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: color.withOpacity(0.15),
        borderColor: color.withOpacity(0.3),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                genre,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
