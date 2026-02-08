/// NYAnime Mobile - Watchlist Screen
///
/// Dedicated watchlist screen with cyberpunk styling, filtering, and management.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/data.dart';
import '../../providers/providers.dart';
import '../home/home_screen.dart' show CyberColors;

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  WatchlistStatus? _filterStatus;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  List<WatchlistItem> _filteredItems(List<WatchlistItem> items) {
    if (_filterStatus == null) return items;
    return items.where((item) => item.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistProvider);
    final filtered = _filteredItems(watchlist);

    return Scaffold(
      backgroundColor: CyberColors.voidBlack,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: CyberColors.backgroundGradient,
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(watchlist.length),

                // Filter chips
                _buildFilterChips(watchlist),

                const SizedBox(height: 8),

                // List
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : _buildWatchlistGrid(filtered),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [CyberColors.cyberPurple, CyberColors.neonCyan],
            ).createShader(bounds),
            child: Text(
              '📚 My Library',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CyberColors.cyberPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CyberColors.cyberPurple.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '$count titles',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: CyberColors.cyberPurple,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildFilterChips(List<WatchlistItem> watchlist) {
    final filters = <(String, WatchlistStatus?, int)>[
      ('All', null, watchlist.length),
      (
        'Watching',
        WatchlistStatus.watching,
        watchlist.where((i) => i.status == WatchlistStatus.watching).length,
      ),
      (
        'Plan to Watch',
        WatchlistStatus.planToWatch,
        watchlist.where((i) => i.status == WatchlistStatus.planToWatch).length,
      ),
      (
        'Completed',
        WatchlistStatus.completed,
        watchlist.where((i) => i.status == WatchlistStatus.completed).length,
      ),
      (
        'On Hold',
        WatchlistStatus.onHold,
        watchlist.where((i) => i.status == WatchlistStatus.onHold).length,
      ),
      (
        'Dropped',
        WatchlistStatus.dropped,
        watchlist.where((i) => i.status == WatchlistStatus.dropped).length,
      ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final (label, status, count) = filters[index];
          final isSelected = _filterStatus == status;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filterStatus = status);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? CyberColors.cyberPurple.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? CyberColors.cyberPurple
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                '$label ($count)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? CyberColors.cyberPurple : Colors.white70,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatchlistGrid(List<WatchlistItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildWatchlistCard(item, index);
      },
    );
  }

  Widget _buildWatchlistCard(WatchlistItem item, int index) {
    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/anime/${item.animeId}');
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: item.animePosterUrl,
                          width: 65,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 65,
                            height: 90,
                            color: CyberColors.glassDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.animeTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Added ${_formatDate(item.addedAt)}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStatusChip(item.status),
                          ],
                        ),
                      ),

                      // Actions
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white54,
                        ),
                        color: const Color(0xFF1E1E2E),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'watching',
                            child: Text(
                              'Mark as Watching',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'completed',
                            child: Text(
                              'Mark as Completed',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'planToWatch',
                            child: Text(
                              'Plan to Watch',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'onHold',
                            child: Text(
                              'On Hold',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text(
                              'Remove',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          HapticFeedback.selectionClick();
                          final notifier = ref.read(watchlistProvider.notifier);
                          switch (value) {
                            case 'watching':
                              notifier.updateStatus(
                                item.animeId,
                                WatchlistStatus.watching,
                              );
                            case 'completed':
                              notifier.updateStatus(
                                item.animeId,
                                WatchlistStatus.completed,
                              );
                            case 'planToWatch':
                              notifier.updateStatus(
                                item.animeId,
                                WatchlistStatus.planToWatch,
                              );
                            case 'onHold':
                              notifier.updateStatus(
                                item.animeId,
                                WatchlistStatus.onHold,
                              );
                            case 'remove':
                              notifier.remove(item.animeId);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 60 * index),
          duration: 300.ms,
        )
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatusChip(WatchlistStatus status) {
    final (label, color) = switch (status) {
      WatchlistStatus.watching => ('Watching', CyberColors.neonCyan),
      WatchlistStatus.completed => ('Completed', const Color(0xFF4CAF50)),
      WatchlistStatus.planToWatch => ('Plan to Watch', const Color(0xFFFFD700)),
      WatchlistStatus.dropped => ('Dropped', const Color(0xFFFF5252)),
      WatchlistStatus.onHold => ('On Hold', Colors.white54),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: CyberColors.cyberPurple.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 20),
          Text(
            'Your library is empty',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse anime and add them\nto your watchlist',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.go('/search'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: CyberColors.neonGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: CyberColors.cyberPurple.withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                'Browse Anime',
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
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
