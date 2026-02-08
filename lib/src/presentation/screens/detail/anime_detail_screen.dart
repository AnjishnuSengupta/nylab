/// NYAnime Mobile - Anime Detail Screen
///
/// Anime detail screen with hero poster, synopsis, episodes list, and countdown timer.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class AnimeDetailScreen extends ConsumerStatefulWidget {
  final int animeId;

  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 300;
    if (showTitle != _showTitle) {
      setState(() => _showTitle = showTitle);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animeAsync = ref.watch(animeDetailByIdProvider(widget.animeId));
    final episodesAsync = ref.watch(animeEpisodesProvider(widget.animeId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: animeAsync.when(
        data: (anime) => anime == null
            ? _buildNotFound()
            : _buildContent(anime, episodesAsync),
        loading: () => const ShimmerDetail(),
        error: (error, stack) => _buildError(error.toString()),
      ),
      floatingActionButton: animeAsync.when(
        data: (anime) => anime != null ? _buildFAB(anime) : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildContent(Anime anime, AsyncValue<List<Episode>> episodesAsync) {
    return Stack(
      children: [
        // Background glow
        Positioned.fill(child: _buildBackgroundGlow(anime.posterUrl)),

        // Main content
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar with poster
            _buildSliverAppBar(anime),

            // Info section
            SliverToBoxAdapter(child: _buildInfoSection(anime)),

            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryPurple,
                  indicatorWeight: 3,
                  labelColor: AppColors.primaryPurple,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTypography.labelLarge,
                  tabs: const [
                    Tab(text: 'Episodes'),
                    Tab(text: 'Related'),
                  ],
                ),
              ),
            ),

            // Tab content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Episodes tab
                  _buildEpisodesList(anime, episodesAsync),
                  // Related tab
                  _buildRelatedSection(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackgroundGlow(String posterUrl) {
    return Stack(
      children: [
        // Blurred poster
        Positioned(
          top: -100,
          left: -50,
          right: -50,
          child: Opacity(
            opacity: 0.3,
            child: CachedNetworkImage(
              imageUrl: posterUrl,
              fit: BoxFit.cover,
              height: 500,
            ),
          ),
        ),
        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Anime anime) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: _showTitle
          ? AppColors.cardBackground
          : Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Share.share(
              'Check out ${anime.displayTitle} on Nylab! 🎬\n${AppConstants.baseUrl}/anime/${anime.id}',
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_rounded, size: 20),
          ),
        ),
      ],
      title: _showTitle
          ? Text(
              anime.displayTitle,
              style: AppTypography.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Poster image
            Hero(
              tag: 'anime_poster_${anime.id}',
              child: CachedNetworkImage(
                imageUrl: anime.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.cardBackground),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.broken_image_rounded, size: 64),
                ),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.backgroundDark.withOpacity(0.5),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),

            // Play button overlay
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    // Play first episode
                    context.push('/player/${anime.id}/1');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Anime anime) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            anime.displayTitle,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (anime.titleEnglish != null &&
              anime.titleEnglish != anime.title) ...[
            const SizedBox(height: 4),
            Text(
              anime.titleEnglish!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Stats row
          _buildStatsRow(anime),
          const SizedBox(height: 16),

          // Genres
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: anime.genres.map((genre) {
              return GenreTag(genre: genre);
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Countdown
          if (anime.hasUpcomingEpisode) ...[
            _buildCountdownSection(anime),
            const SizedBox(height: 20),
          ],

          // Synopsis
          _buildSynopsisSection(anime),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Anime anime) {
    return GlassmorphismCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.star_rounded,
            anime.score.toStringAsFixed(1),
            'Score',
            AppColors.accentGold,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.visibility_rounded,
            anime.members.compactNumber(),
            'Members',
            AppColors.primaryCyan,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.movie_rounded,
            anime.episodeCount?.toString() ?? '?',
            'Episodes',
            AppColors.primaryPink,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.access_time_rounded,
            anime.status,
            'Status',
            AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: AppColors.borderColor);
  }

  Widget _buildCountdownSection(Anime anime) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
      borderColor: AppColors.primaryPurple.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Next Episode',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CountdownTimer(
            targetDate: anime.nextEpisodeAt!,
            episodeNumber: anime.nextEpisodeNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildSynopsisSection(Anime anime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          anime.synopsis,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesList(
    Anime anime,
    AsyncValue<List<Episode>> episodesAsync,
  ) {
    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return Center(
            child: Text(
              'No episodes available',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EpisodeCard(
                episode: episode,
                animePosterUrl: anime.posterUrl,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/player/${anime.id}/${episode.id}');
                },
              ),
            );
          },
        );
      },
      loading: () => const ShimmerEpisodeList(),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load episodes',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.accentRed),
        ),
      ),
    );
  }

  Widget _buildRelatedSection() {
    // For now, show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_rounded,
            size: 48,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Related anime coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(Anime anime) {
    final watchlist = ref.watch(watchlistProvider);
    final isInWatchlist = watchlist.any((item) => item.animeId == anime.id);

    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        if (isInWatchlist) {
          ref.read(watchlistProvider.notifier).remove(anime.id);
        } else {
          ref.read(watchlistProvider.notifier).add(anime);
        }
      },
      backgroundColor: isInWatchlist
          ? AppColors.accentRed
          : AppColors.primaryPurple,
      icon: Icon(
        isInWatchlist
            ? Icons.bookmark_remove_rounded
            : Icons.bookmark_add_rounded,
      ),
      label: Text(
        isInWatchlist ? 'Remove' : 'Add to List',
        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text('Anime not found', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.accentRed,
          ),
          const SizedBox(height: 16),
          Text('Failed to load', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () =>
                ref.invalidate(animeDetailByIdProvider(widget.animeId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Sliver tab bar delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.backgroundDark, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
