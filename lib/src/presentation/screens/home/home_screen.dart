/// NYAnime Mobile - Cyberpunk Home Screen
///
/// Futuristic cyberpunk-themed home screen with glassmorphism,
/// neon effects, parallax animations, and liquid-glass interactions.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../providers/providers.dart';

// ═══════════════════════════════════════════════════════════════════════════
// COLOR CONSTANTS - CYBERPUNK PALETTE
// ═══════════════════════════════════════════════════════════════════════════

class CyberColors {
  CyberColors._();

  static const Color cyberPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color glassDark = Color(0xFF1E1E2E);
  static const Color glassLight = Color(0xFF2A2A3E);
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF2D2B55);
  static const Color voidBlack = Color(0xFF0A0A0A);
  static const Color deepBlue = Color(0xFF1A1A2E);
  static const Color midnightBlue = Color(0xFF16213E);
  static const Color darkVoid = Color(0xFF0F0F23);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [voidBlack, deepBlue, midnightBlue, darkVoid],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [cyberPurple, neonCyan],
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [neonCyan, cyberPurple],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN HOME SCREEN WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _carouselController = PageController(
    viewportFraction: 0.85,
  );

  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  Timer? _autoPlayTimer;
  int _currentCarouselPage = 0;
  double _scrollOffset = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scrollController.addListener(_onScroll);
    _startAutoPlay();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_carouselController.hasClients) {
        final trending = ref.read(trendingAnimeProvider).valueOrNull ?? [];
        if (trending.isNotEmpty) {
          _currentCarouselPage = (_currentCarouselPage + 1) % trending.length;
          _carouselController.animateToPage(
            _currentCarouselPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  void _pauseAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  void _resumeAutoPlay() {
    _startAutoPlay();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _carouselController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    ref.invalidate(trendingAnimeProvider);
    ref.invalidate(seasonalAnimeProvider);
    ref.invalidate(topAiringAnimeProvider);
    ref.invalidate(mostPopularAnimeProvider);

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CyberColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Layer 1: Floating neon particles (transparent overlay)
            _buildParticleField(),

            // Layer 2: Matrix rain effect on refresh
            if (_isRefreshing) _buildMatrixRain(),

            // Layer 3: Main content
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: CyberColors.neonCyan,
                backgroundColor: CyberColors.glassDark,
                child: ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.zero,
                  children: [
                    // Cyber Header
                    _buildCyberHeader(),

                    // Hero Carousel
                    _buildHeroSection(),

                    // Continue Watching
                    _buildContinueWatchingSection(),

                    // New This Week
                    _buildNewThisWeekSection(),

                    // Popular Now
                    _buildPopularNowSection(),

                    // Countdowns
                    _buildCountdownsSection(),

                    // Bottom padding for nav bar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // FLOATING NEON PARTICLES
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildParticleField() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: NeonParticlePainter(
                animationValue: _particleController.value,
                scrollOffset: _scrollOffset,
                particleCount: 25,
              ),
            );
          },
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // MATRIX RAIN EFFECT
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildMatrixRain() {
    return Positioned.fill(
      child: IgnorePointer(
        child:
            CustomPaint(
                  painter: MatrixRainPainter(
                    animationValue: _particleController.value,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 300.ms)
                .then()
                .fadeOut(delay: 800.ms, duration: 400.ms),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // CYBER HEADER (replaces SliverAppBar)
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildCyberHeader() {
    final opacity = (1.0 - (_scrollOffset / 200)).clamp(0.2, 1.0);

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NYANIME Logo with gradient glow
            _buildNeonLogo(),

            // Right actions: Search + Profile
            Row(
              children: [
                _buildGlassSearchButton(),
                const SizedBox(width: 12),
                _buildProfileRing(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing NYANIME text
        ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [CyberColors.cyberPurple, CyberColors.neonCyan],
              ).createShader(bounds),
              child: Text(
                'NYANIME',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: CyberColors.cyberPurple.withValues(alpha: 0.8),
                      blurRadius: 20,
                    ),
                    Shadow(
                      color: CyberColors.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            )
            .animate(controller: _glowController)
            .shimmer(
              duration: 2000.ms,
              color: CyberColors.neonCyan.withValues(alpha: 0.3),
            ),
        const SizedBox(height: 4),
        Text(
          'What are you watching today?',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildGlassSearchButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/search');
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: CyberColors.cyberPurple.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: CyberColors.cyberPurple.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildProfileRing() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/profile');
      },
      child: Stack(
        children: [
          // Neon gradient border ring
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [CyberColors.cyberPurple, CyberColors.neonCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: CyberColors.cyberPurple.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CyberColors.voidBlack,
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/100?u=nyanime'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Pulsing notification badge
          Positioned(
            right: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.2);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: CyberColors.neonCyan,
                  shape: BoxShape.circle,
                  border: Border.all(color: CyberColors.voidBlack, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: CyberColors.neonCyan.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: CyberColors.voidBlack,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8));
  }

  // ═════════════════════════════════════════════════════════════════════════
  // HERO CAROUSEL SECTION
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection() {
    final trendingAsync = ref.watch(trendingAnimeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: _buildSectionHeader('🔥 Trending Now'),
        ),
        trendingAsync.when(
          data: (animeList) => _buildHeroCarousel(animeList),
          loading: () => _buildCarouselShimmer(),
          error: (error, _) => _buildErrorCard(error.toString()),
        ),
      ],
    );
  }

  Widget _buildHeroCarousel(List<Anime> animeList) {
    if (animeList.isEmpty) {
      return _buildEmptyState('No trending anime available');
    }

    return GestureDetector(
      onPanDown: (_) => _pauseAutoPlay(),
      onPanEnd: (_) => _resumeAutoPlay(),
      onPanCancel: () => _resumeAutoPlay(),
      child: SizedBox(
        height: 560,
        child: PageView.builder(
          controller: _carouselController,
          itemCount: animeList.length,
          onPageChanged: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentCarouselPage = index);
          },
          itemBuilder: (context, index) {
            final anime = animeList[index];
            return _buildHeroCard(anime, index);
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(Anime anime, int index) {
    return AnimatedBuilder(
      animation: _carouselController,
      builder: (context, child) {
        double value = 1.0;
        if (_carouselController.position.haveDimensions) {
          value = (_carouselController.page ?? 0) - index;
          value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
        }

        // Parallax effect
        final parallaxOffset = (_scrollOffset * 0.15).clamp(-15.0, 15.0);

        return Transform.translate(
          offset: Offset(-parallaxOffset, 0),
          child: Transform.scale(
            scale: Curves.easeOut.transform(value),
            child: child,
          ),
        );
      },
      child: _buildCarouselCard(anime),
    );
  }

  Widget _buildCarouselCard(Anime anime) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/anime/${anime.id}');
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        // Holo-lift effect handled by animation
      },
      child:
          Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: CyberColors.cyberPurple.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background poster
                      Hero(
                        tag: 'anime_poster_${anime.id}',
                        child: CachedNetworkImage(
                          imageUrl: anime.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: CyberColors.glassDark),
                          errorWidget: (_, _, _) => Container(
                            color: CyberColors.glassDark,
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                      ),

                      // Glass overlay (35% opacity)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              CyberColors.voidBlack.withValues(alpha: 0.35),
                              CyberColors.voidBlack.withValues(alpha: 0.85),
                              CyberColors.voidBlack,
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),

                      // Glassmorphism content card
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Genres
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: anime.genres.take(2).map((genre) {
                                      return _buildNeonGenreChip(genre);
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),

                                  // Title
                                  Text(
                                    anime.displayTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Subtitle info
                                  Text(
                                    '${anime.type} • ${anime.episodeCount ?? '?'} eps • ${anime.status}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Score and countdown
                                  Row(
                                    children: [
                                      // Score
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: CyberColors.neonGradient,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              anime.score.toStringAsFixed(1),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),

                                      // Next episode countdown
                                      if (anime.hasUpcomingEpisode)
                                        _buildMiniCountdown(anime),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tap glow effect
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            splashColor: CyberColors.cyberPurple.withValues(
                              alpha: 0.3,
                            ),
                            highlightColor: CyberColors.neonCyan.withValues(
                              alpha: 0.1,
                            ),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/anime/${anime.id}');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),
    );
  }

  Widget _buildNeonGenreChip(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CyberColors.cyberPurple.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CyberColors.cyberPurple.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        genre,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMiniCountdown(Anime anime) {
    final timeUntil = anime.nextEpisodeAt?.difference(DateTime.now());
    if (timeUntil == null || timeUntil.isNegative) return const SizedBox();

    final days = timeUntil.inDays;
    final hours = timeUntil.inHours.remainder(24);
    final minutes = timeUntil.inMinutes.remainder(60);

    String countdownText;
    if (days > 0) {
      countdownText = 'Ep ${anime.nextEpisodeNumber} • ${days}d ${hours}h';
    } else if (hours > 0) {
      countdownText = 'Ep ${anime.nextEpisodeNumber} • ${hours}h ${minutes}m';
    } else {
      countdownText = 'Ep ${anime.nextEpisodeNumber} • ${minutes}m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CyberColors.neonCyan.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberColors.neonCyan.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 14,
            color: CyberColors.neonCyan,
          ),
          const SizedBox(width: 4),
          Text(
            countdownText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CyberColors.neonCyan,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // CONTINUE WATCHING SECTION
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildContinueWatchingSection() {
    final continueWatching = ref.watch(continueWatchingProvider);

    if (continueWatching.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: _buildSectionHeader('▶️ Continue Watching'),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: continueWatching.length,
            itemBuilder: (context, index) {
              final progress = continueWatching[index];

              return Dismissible(
                key: Key('continue_${progress.animeId}'),
                direction: DismissDirection.up,
                onDismissed: (_) {
                  HapticFeedback.heavyImpact();
                },
                child: _buildContinueWatchingCardFromProgress(progress, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingCardFromProgress(
    WatchProgress progress,
    int index,
  ) {
    // Try to get anime info from mock data for display
    final anime = MockData.getAnimeById(progress.animeId);
    final posterUrl = anime?.posterUrl ?? '';
    final title = anime?.displayTitle ?? 'Anime #${progress.animeId}';
    final epCount = anime?.episodeCount;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/player/${progress.animeId}/${progress.episodeId}');
      },
      child:
          Container(
                width: 160,
                height: 260,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    // Glass card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CyberColors.glassDark.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Poster
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: posterUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: posterUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (_, _) => Container(
                                            color: CyberColors.shimmerBase,
                                          ),
                                          errorWidget: (_, _, _) => Container(
                                            color: CyberColors.shimmerBase,
                                            child: const Icon(
                                              Icons.movie_outlined,
                                              color: CyberColors.cyberPurple,
                                              size: 32,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: CyberColors.shimmerBase,
                                          child: const Icon(
                                            Icons.movie_outlined,
                                            color: CyberColors.cyberPurple,
                                            size: 32,
                                          ),
                                        ),
                                ),
                              ),

                              // Info section
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Ep ${progress.episodeNumber}${epCount != null ? '/$epCount' : ''}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Progress ring overlay
                    Positioned(
                      right: 8,
                      top: 130,
                      child: _buildProgressRing(progress.progressPercent * 100),
                    ),

                    // Play orb with pulse
                    Positioned(right: 8, top: 8, child: _buildPlayOrb()),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index))
              .slideX(begin: 0.2, end: 0),
    );
  }

  Widget _buildProgressRing(double percent) {
    return SizedBox(
      width: 45,
      height: 45,
      child: Stack(
        children: [
          // Ring background
          CustomPaint(
            size: const Size(45, 45),
            painter: ProgressRingPainter(
              progress: percent / 100,
              strokeWidth: 3.5,
              gradient: CyberColors.progressGradient,
            ),
          ),
          // Percentage text
          Center(
            child: Text(
              '${percent.toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayOrb() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.08);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: CyberColors.neonGradient,
          boxShadow: [
            BoxShadow(
              color: CyberColors.cyberPurple.withValues(alpha: 0.6),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // NEW THIS WEEK SECTION
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildNewThisWeekSection() {
    final seasonalAsync = ref.watch(seasonalAnimeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: _buildSectionHeader(
            '✨ New This Week',
            onSeeAll: () => context.push('/browse?filter=new'),
          ),
        ),
        seasonalAsync.when(
          data: (animeList) => _buildStaggeredGrid(animeList.take(6).toList()),
          loading: () => _buildGridShimmer(),
          error: (error, _) => _buildErrorCard(error.toString()),
        ),
      ],
    );
  }

  Widget _buildStaggeredGrid(List<Anime> animeList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          // Staggered entry animation
          return _buildGlassPosterCard(anime, index);
        },
      ),
    );
  }

  Widget _buildGlassPosterCard(Anime anime, int index) {
    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/anime/${anime.id}');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    // Poster
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: anime.posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        anime.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 * index))
        .scale(
          begin: const Offset(0.9, 0.9),
          delay: Duration(milliseconds: 80 * index),
          duration: 300.ms,
        );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // POPULAR NOW SECTION
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPopularNowSection() {
    final popularAsync = ref.watch(mostPopularAnimeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: _buildSectionHeader(
            '🔥 Popular Now',
            onSeeAll: () => context.push('/browse?filter=popular'),
          ),
        ),
        popularAsync.when(
          data: (animeList) => _buildPopularRow(animeList.take(6).toList()),
          loading: () => _buildRowShimmer(),
          error: (error, _) => _buildErrorCard(error.toString()),
        ),
      ],
    );
  }

  Widget _buildPopularRow(List<Anime> animeList) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return _buildPopularCard(anime, index);
        },
      ),
    );
  }

  Widget _buildPopularCard(Anime anime, int index) {
    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/anime/${anime.id}');
          },
          child: Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster with shimmer effect and genre badge
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: anime.posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, _) => Shimmer.fromColors(
                            baseColor: CyberColors.shimmerBase,
                            highlightColor: CyberColors.shimmerHighlight,
                            child: Container(color: CyberColors.shimmerBase),
                          ),
                        ),
                      ),
                      // Genre badge
                      if (anime.genres.isNotEmpty)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CyberColors.cyberPurple.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              anime.genres.first,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      // Score badge
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CyberColors.voidBlack.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                anime.score.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  anime.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.15, end: 0);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // COUNTDOWNS SECTION
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildCountdownsSection() {
    final trendingAsync = ref.watch(trendingAnimeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: _buildSectionHeader('⏰ Upcoming Episodes'),
        ),
        trendingAsync.when(
          data: (animeList) {
            final upcoming = animeList
                .where((a) => a.hasUpcomingEpisode)
                .take(4)
                .toList();
            if (upcoming.isEmpty) {
              return _buildEmptyState('No upcoming episodes');
            }
            return _buildCountdownsList(upcoming);
          },
          loading: () => _buildRowShimmer(),
          error: (error, _) => _buildErrorCard(error.toString()),
        ),
      ],
    );
  }

  Widget _buildCountdownsList(List<Anime> animeList) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return _buildCountdownCard(anime, index);
        },
      ),
    );
  }

  Widget _buildCountdownCard(Anime anime, int index) {
    final timeUntil = anime.nextEpisodeAt?.difference(DateTime.now());
    if (timeUntil == null || timeUntil.isNegative) return const SizedBox();

    final days = timeUntil.inDays;
    final hours = timeUntil.inHours.remainder(24);
    final minutes = timeUntil.inMinutes.remainder(60);

    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/anime/${anime.id}');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CyberColors.neonCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Mini poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: anime.posterUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            anime.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Episode ${anime.nextEpisodeNumber}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Live countdown timer
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: CyberColors.neonGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${days}d ${hours}h ${minutes}m ⏰',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.2, end: 0);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onSeeAll();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CyberColors.cyberPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CyberColors.cyberPurple.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CyberColors.cyberPurple,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: CyberColors.cyberPurple,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SHIMMER LOADING STATES
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildCarouselShimmer() {
    return SizedBox(
      height: 560,
      child: PageView.builder(
        itemCount: 3,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Shimmer.fromColors(
              baseColor: CyberColors.shimmerBase,
              highlightColor: CyberColors.shimmerHighlight,
              child: Container(
                decoration: BoxDecoration(
                  color: CyberColors.shimmerBase,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: CyberColors.shimmerBase,
            highlightColor: CyberColors.shimmerHighlight,
            child: Container(
              decoration: BoxDecoration(
                color: CyberColors.shimmerBase,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRowShimmer() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: CyberColors.shimmerBase,
            highlightColor: CyberColors.shimmerHighlight,
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: CyberColors.shimmerBase,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ERROR & EMPTY STATES
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.accentRed,
          ),
          const SizedBox(height: 12),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _onRefresh();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: CyberColors.neonGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CyberColors.glassDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberColors.cyberPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 40,
              color: CyberColors.cyberPurple.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════

/// Neon particle painter for floating particles effect
class NeonParticlePainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;
  final int particleCount;

  NeonParticlePainter({
    required this.animationValue,
    required this.scrollOffset,
    this.particleCount = 25,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < particleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final particleSize = 2.0 + random.nextDouble() * 4.0;

      // Parallax drift based on scroll and animation
      final parallaxFactor = 0.2 + (i % 5) * 0.1;
      final driftX = math.sin(animationValue * math.pi * 2 + i) * 30;
      final driftY = (scrollOffset * parallaxFactor) % size.height;

      final x = (baseX + driftX) % size.width;
      final y = (baseY - driftY + size.height) % size.height;

      // Alternate between purple and cyan
      final color = i % 2 == 0 ? CyberColors.cyberPurple : CyberColors.neonCyan;

      // Pulsing opacity
      final opacity =
          0.3 + 0.4 * math.sin(animationValue * math.pi * 2 + i * 0.5);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.1, 0.7))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 2);

      canvas.drawCircle(Offset(x, y), particleSize, paint);

      // Inner glow
      final innerPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.5);
      canvas.drawCircle(Offset(x, y), particleSize * 0.3, innerPaint);
    }
  }

  @override
  bool shouldRepaint(NeonParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}

/// Matrix rain effect painter for pull-to-refresh
class MatrixRainPainter extends CustomPainter {
  final double animationValue;

  MatrixRainPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    const chars = 'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789';

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int col = 0; col < size.width / 20; col++) {
      final x = col * 20.0;
      final speed = 0.5 + random.nextDouble() * 0.5;
      final startOffset = random.nextDouble();

      for (int row = 0; row < 15; row++) {
        final progress =
            ((animationValue * speed + startOffset + row * 0.05) % 1.0);
        final y = progress * size.height;

        final charIndex = random.nextInt(chars.length);
        final char = chars[charIndex];

        final opacity = (1.0 - (row / 15)).clamp(0.1, 0.8);

        textPainter.text = TextSpan(
          text: char,
          style: TextStyle(
            color: CyberColors.neonCyan.withValues(alpha: opacity * 0.6),
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(MatrixRainPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Progress ring painter for continue watching cards
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  ProgressRingPainter({
    required this.progress,
    this.strokeWidth = 3.0,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
