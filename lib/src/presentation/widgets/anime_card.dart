/// NYAnime Mobile - Anime Card Widget
///
/// Beautiful anime card with hover effects and hero animation support.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/core.dart';
import '../../data/models/models.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showScore;
  final bool showProgress;
  final double? progress;
  final String? heroTag;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onTap,
    this.width,
    this.height,
    this.showScore = true,
    this.showProgress = false,
    this.progress,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? AppConstants.animeCardWidth;
    final cardHeight = height ?? AppConstants.animeCardHeight;

    final imageWidget = CachedNetworkImage(
      imageUrl: anime.posterUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmer(cardWidth, cardHeight),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: SizedBox(
        width: cardWidth,
        height: cardHeight + 48,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlays
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero animated image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    child: heroTag != null
                        ? Hero(tag: heroTag!, child: imageWidget)
                        : imageWidget,
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Score badge
                  if (showScore && anime.score > 0)
                    Positioned(top: 8, right: 8, child: _buildScoreBadge()),

                  // Airing indicator
                  if (anime.isAiring)
                    Positioned(top: 8, left: 8, child: _buildAiringBadge()),

                  // Progress bar
                  if (showProgress && progress != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildProgressBar(),
                    ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                anime.displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.animeSubtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(double width, double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(
          color: _getScoreColor(anime.score).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: _getScoreColor(anime.score),
          ),
          const SizedBox(width: 4),
          Text(
            anime.score.toStringAsFixed(1),
            style: AppTypography.labelSmall.copyWith(
              color: _getScoreColor(anime.score),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiringBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'AIRING',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: AppColors.backgroundDark.withOpacity(0.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return AppColors.accentGold;
    if (score >= 7.5) return AppColors.accentGreen;
    if (score >= 6.5) return AppColors.primaryCyan;
    return AppColors.textSecondary;
  }
}

/// Shimmer loading placeholder for anime card
class AnimeCardShimmer extends StatelessWidget {
  final double? width;
  final double? height;

  const AnimeCardShimmer({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? AppConstants.animeCardWidth;
    final cardHeight = height ?? AppConstants.animeCardHeight;

    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight + 48,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: cardHeight,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 14,
              width: cardWidth * 0.8,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 12,
              width: cardWidth * 0.5,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
