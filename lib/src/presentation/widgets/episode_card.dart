/// NYAnime Mobile - Episode Card Widget
///
/// Card component for displaying episode information.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/core.dart';
import '../../data/models/models.dart';

class EpisodeCard extends StatelessWidget {
  final Episode episode;
  final VoidCallback? onTap;
  final double? progress;
  final bool isCurrentlyPlaying;
  final String? animePosterUrl;

  const EpisodeCard({
    super.key,
    required this.episode,
    this.onTap,
    this.progress,
    this.isCurrentlyPlaying = false,
    this.animePosterUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        height: AppConstants.episodeCardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying
              ? AppColors.primaryPurple.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isCurrentlyPlaying
                ? AppColors.primaryPurple.withOpacity(0.5)
                : AppColors.cardBorder,
            width: isCurrentlyPlaying ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            _buildThumbnail(),

            // Episode info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Episode number and badges
                    Row(
                      children: [
                        Text(
                          episode.shortTitle,
                          style: AppTypography.episodeNumber,
                        ),
                        if (episode.isFiller) ...[
                          const SizedBox(width: 8),
                          _buildBadge('FILLER', AppColors.accentOrange),
                        ],
                        if (episode.isRecap) ...[
                          const SizedBox(width: 8),
                          _buildBadge('RECAP', AppColors.textTertiary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      episode.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium,
                    ),

                    const SizedBox(height: 4),

                    // Duration and progress
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          episode.durationString,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (progress != null && progress! > 0) ...[
                          const SizedBox(width: 12),
                          Expanded(child: _buildProgressIndicator()),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Play button
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCurrentlyPlaying
                      ? AppColors.primaryPurple
                      : AppColors.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCurrentlyPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: isCurrentlyPlaying
                      ? Colors.white
                      : AppColors.primaryPurple,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final imageUrl = episode.thumbnailUrl.isNotEmpty
        ? episode.thumbnailUrl
        : animePosterUrl ?? '';

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.borderRadiusMedium - 1),
            bottomLeft: Radius.circular(AppConstants.borderRadiusMedium - 1),
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 120,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(width: 120, color: AppColors.shimmerBase),
            errorWidget: (context, url, error) => Container(
              width: 120,
              color: AppColors.cardBackground,
              child: const Icon(
                Icons.broken_image_rounded,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
        // Progress overlay on thumbnail
        if (progress != null && progress! > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withOpacity(0.5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress! * 100).toInt()}%',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primaryPurple,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
