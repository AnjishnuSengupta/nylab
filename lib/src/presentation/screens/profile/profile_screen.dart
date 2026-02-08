/// NYAnime Mobile - Profile Screen
///
/// Profile screen with user stats, watch history, and settings.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStats = ref.watch(userStatsProvider);
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // Profile header
              SliverToBoxAdapter(child: _buildProfileHeader()),

              // Stats cards
              SliverToBoxAdapter(child: _buildStatsSection(userStats)),

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
                    tabs: [
                      Tab(text: 'Watchlist (${watchlist.length})'),
                      const Tab(text: 'Stats'),
                      const Tab(text: 'Settings'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildWatchlistTab(watchlist),
                _buildStatsTab(userStats),
                _buildSettingsTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anime Enthusiast',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since June 2024',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge('👑 Premium', AppColors.accentGold),
                    const SizedBox(width: 8),
                    _buildBadge('🔥 10 Day Streak', AppColors.accentRed),
                  ],
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Edit profile
            },
            icon: const Icon(
              Icons.edit_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatsSection(UserStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphismCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(
              stats.totalAnimeCompleted.toString(),
              'Watched',
              Icons.visibility_rounded,
              AppColors.primaryPurple,
            ),
            _buildStatDivider(),
            _buildStatColumn(
              (stats.totalWatchTimeMinutes ~/ 60).toString(),
              'Hours',
              Icons.schedule_rounded,
              AppColors.primaryCyan,
            ),
            _buildStatDivider(),
            _buildStatColumn(
              stats.totalEpisodesWatched.toString(),
              'Episodes',
              Icons.play_circle_rounded,
              AppColors.primaryPink,
            ),
            _buildStatDivider(),
            _buildStatColumn(
              stats.averageScore.toStringAsFixed(1),
              'Avg Score',
              Icons.star_rounded,
              AppColors.accentGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
    return Container(width: 1, height: 50, color: AppColors.borderColor);
  }

  Widget _buildWatchlistTab(List<WatchlistItem> watchlist) {
    if (watchlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Your watchlist is empty',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse anime and add them\nto your watchlist',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: watchlist.length,
      itemBuilder: (context, index) {
        final item = watchlist[index];
        return _buildWatchlistItem(item);
      },
    );
  }

  Widget _buildWatchlistItem(WatchlistItem item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/anime/${item.animeId}');
      },
      child: GlassmorphismCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
              child: CachedNetworkImage(
                imageUrl: item.animePosterUrl,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.cardBackground),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.broken_image_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.animeTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Added ${_formatDate(item.addedAt)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(item.status),
                ],
              ),
            ),
            // More options
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
              ),
              color: AppColors.cardBackground,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'watching',
                  child: Text('Mark as Watching'),
                ),
                const PopupMenuItem(
                  value: 'completed',
                  child: Text('Mark as Completed'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove from List'),
                ),
              ],
              onSelected: (value) {
                HapticFeedback.selectionClick();
                if (value == 'remove') {
                  ref.read(watchlistProvider.notifier).remove(item.animeId);
                } else if (value == 'watching') {
                  ref
                      .read(watchlistProvider.notifier)
                      .updateStatus(item.animeId, WatchlistStatus.watching);
                } else if (value == 'completed') {
                  ref
                      .read(watchlistProvider.notifier)
                      .updateStatus(item.animeId, WatchlistStatus.completed);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(WatchlistStatus status) {
    final (label, color) = switch (status) {
      WatchlistStatus.watching => ('Watching', AppColors.accentGreen),
      WatchlistStatus.completed => ('Completed', AppColors.primaryCyan),
      WatchlistStatus.planToWatch => ('Plan to Watch', AppColors.accentGold),
      WatchlistStatus.dropped => ('Dropped', AppColors.accentRed),
      WatchlistStatus.onHold => ('On Hold', AppColors.textTertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatsTab(UserStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre distribution pie chart
          Text(
            'Genre Distribution',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GlassmorphismCard(
            padding: const EdgeInsets.all(20),
            child: SizedBox(height: 200, child: _buildPieChart(stats)),
          ),
          const SizedBox(height: 24),

          // Weekly activity bar chart
          Text(
            'Weekly Activity',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GlassmorphismCard(
            padding: const EdgeInsets.all(20),
            child: SizedBox(height: 200, child: _buildBarChart()),
          ),
          const SizedBox(height: 24),

          // Score distribution
          Text(
            'Your Ratings',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildScoreDistribution(stats),
        ],
      ),
    );
  }

  Widget _buildPieChart(UserStats stats) {
    final genreData = stats.genreDistribution;
    final colors = [
      AppColors.genreAction,
      AppColors.genreRomance,
      AppColors.genreComedy,
      AppColors.genreFantasy,
      AppColors.primaryCyan,
      AppColors.accentGold,
    ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: genreData.entries.take(6).toList().asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final genre = entry.value;
                return PieChartSectionData(
                  value: genre.value.toDouble(),
                  title: '${genre.value}',
                  radius: 45,
                  titleStyle: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  color: colors[index % colors.length],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: genreData.entries.take(6).toList().asMap().entries.map((
              entry,
            ) {
              final index = entry.key;
              final genre = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        genre.key,
                        style: AppTypography.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [2.0, 1.5, 3.0, 2.5, 4.0, 5.0, 4.5]; // Hours watched

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: AppColors.borderColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[value.toInt()],
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: values.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                gradient: AppColors.primaryGradient,
              ),
            ],
          );
        }).toList(),
        maxY: 6,
      ),
    );
  }

  Widget _buildScoreDistribution(UserStats stats) {
    final scores = stats.scoreDistribution;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: scores.entries
            .map((entry) {
              final score = entry.key;
              final count = entry.value;
              final maxCount = scores.values.reduce((a, b) => a > b ? a : b);
              final progress = maxCount > 0 ? count / maxCount : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        score.toString(),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.accentGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.cardBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(score),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        count.toString(),
                        textAlign: TextAlign.right,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 9) return AppColors.accentGreen;
    if (score >= 7) return AppColors.primaryCyan;
    if (score >= 5) return AppColors.accentGold;
    if (score >= 3) return AppColors.primaryPink;
    return AppColors.accentRed;
  }

  Widget _buildSettingsTab() {
    final isDarkMode = ref.watch(darkModeProvider);
    final isAutoplay = ref.watch(autoplayProvider);
    final isOfflineMode = ref.watch(offlineModeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Appearance
        _buildSettingsSection('Appearance', [
          _buildSettingsTile(
            icon: Icons.dark_mode_rounded,
            iconColor: AppColors.primaryPurple,
            title: 'Dark Mode',
            subtitle: 'Always on for that anime aesthetic',
            trailing: Switch.adaptive(
              value: isDarkMode,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(darkModeProvider.notifier).state = value;
              },
              activeColor: AppColors.primaryPurple,
            ),
          ),
        ]),

        // Playback
        _buildSettingsSection('Playback', [
          _buildSettingsTile(
            icon: Icons.play_circle_filled_rounded,
            iconColor: AppColors.accentGreen,
            title: 'Autoplay',
            subtitle: 'Automatically play next episode',
            trailing: Switch.adaptive(
              value: isAutoplay,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(autoplayProvider.notifier).state = value;
              },
              activeColor: AppColors.primaryPurple,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.download_rounded,
            iconColor: AppColors.primaryCyan,
            title: 'Offline Mode',
            subtitle: 'Download episodes for offline viewing',
            trailing: Switch.adaptive(
              value: isOfflineMode,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(offlineModeProvider.notifier).state = value;
              },
              activeColor: AppColors.primaryPurple,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.high_quality_rounded,
            iconColor: AppColors.accentGold,
            title: 'Default Quality',
            subtitle: 'Auto (720p)',
            onTap: () {
              // TODO: Show quality picker
            },
          ),
        ]),

        // Account
        _buildSettingsSection('Account', [
          _buildSettingsTile(
            icon: Icons.person_rounded,
            iconColor: AppColors.primaryPink,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Edit profile
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_rounded,
            iconColor: AppColors.accentRed,
            title: 'Notifications',
            onTap: () {
              // TODO: Notification settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.security_rounded,
            iconColor: AppColors.accentGreen,
            title: 'Privacy & Security',
            onTap: () {
              // TODO: Privacy settings
            },
          ),
        ]),

        // Support
        _buildSettingsSection('Support', [
          _buildSettingsTile(
            icon: Icons.help_rounded,
            iconColor: AppColors.textSecondary,
            title: 'Help Center',
            onTap: () {
              // TODO: Help
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_rounded,
            iconColor: AppColors.textSecondary,
            title: 'About Nylab',
            subtitle: 'Version 1.0.0',
            onTap: () {
              // TODO: About
            },
          ),
        ]),

        const SizedBox(height: 20),

        // Logout button
        Center(
          child: TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // TODO: Logout
            },
            child: Text(
              'Log Out',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.accentRed,
              ),
            ),
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        GlassmorphismCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                )
              : null),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
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
