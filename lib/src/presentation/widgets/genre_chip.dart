/// NYAnime Mobile - Genre Chip Widget
///
/// Stylized genre chip with color coding.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/core.dart';

class GenreChip extends StatelessWidget {
  final String genre;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showIcon;

  const GenreChip({
    super.key,
    required this.genre,
    this.isSelected = false,
    this.onTap,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getGenreColor(genre);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: AppConstants.quickAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusCircular,
          ),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                _getGenreIcon(genre),
                size: 14,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              genre,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getGenreIcon(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return Icons.flash_on_rounded;
      case 'comedy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'drama':
        return Icons.theater_comedy_rounded;
      case 'fantasy':
        return Icons.auto_awesome_rounded;
      case 'horror':
        return Icons.dark_mode_rounded;
      case 'romance':
        return Icons.favorite_rounded;
      case 'sci-fi':
        return Icons.rocket_launch_rounded;
      case 'slice of life':
        return Icons.coffee_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'supernatural':
        return Icons.visibility_rounded;
      case 'adventure':
        return Icons.explore_rounded;
      case 'mystery':
        return Icons.help_rounded;
      default:
        return Icons.movie_rounded;
    }
  }
}

/// Genre chips wrap for multiple genres
class GenreChipsWrap extends StatelessWidget {
  final List<String> genres;
  final List<String> selectedGenres;
  final ValueChanged<String>? onGenreToggle;
  final bool selectable;

  const GenreChipsWrap({
    super.key,
    required this.genres,
    this.selectedGenres = const [],
    this.onGenreToggle,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) {
        return GenreChip(
          genre: genre,
          isSelected: selectedGenres.contains(genre),
          onTap: selectable ? () => onGenreToggle?.call(genre) : null,
        );
      }).toList(),
    );
  }
}

/// Small genre tag for anime cards
class GenreTag extends StatelessWidget {
  final String genre;

  const GenreTag({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getGenreColor(genre);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        genre,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
