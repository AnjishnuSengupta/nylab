/// NYAnime Mobile - Player Screen
///
/// Video player screen with video_player + chewie integration, playback controls,
/// subtitle support, and watch progress tracking.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../providers/providers.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final int animeId;
  final int episodeId;

  const PlayerScreen({
    super.key,
    required this.animeId,
    required this.episodeId,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _showControls = true;
  double _currentPosition = 0;
  double _totalDuration = 1;
  bool _isBuffering = false;
  int _currentEpisodeId = 0;

  @override
  void initState() {
    super.initState();
    _currentEpisodeId = widget.episodeId;
    // Set to landscape for video playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Get episode data
    final episode = MockData.getEpisodeById(widget.animeId, _currentEpisodeId);
    if (episode == null) return;

    // Get video URL - using a sample video for demo
    final videoUrl =
        episode.streamUrl ??
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    // Initialize video player
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    );

    await _videoController!.initialize();

    // Configure chewie
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      playbackSpeeds: AppConstants.playbackSpeeds,
      showControls: true,
      showControlsOnInitialize: true,
      placeholder: _buildPlaceholder(),
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryPurple,
        handleColor: AppColors.primaryPurple,
        bufferedColor: AppColors.primaryPurple.withAlpha(77),
        backgroundColor: Colors.white24,
      ),
      errorBuilder: (context, errorMessage) {
        return _buildErrorState(errorMessage);
      },
    );

    // Listen to video position updates
    _videoController!.addListener(_onVideoUpdate);

    setState(() {
      _isInitialized = true;
      _totalDuration = _videoController!.value.duration.inMilliseconds
          .toDouble();
    });
  }

  void _onVideoUpdate() {
    if (!mounted || _videoController == null) return;

    final value = _videoController!.value;

    if (value.isInitialized) {
      setState(() {
        _currentPosition = value.position.inMilliseconds.toDouble();
        _totalDuration = value.duration.inMilliseconds.toDouble();
        _isBuffering = value.isBuffering;
      });

      // Update watch progress periodically
      _updateWatchProgress();

      // Check if video finished
      if (value.position >= value.duration && value.duration.inSeconds > 0) {
        _onEpisodeFinished();
      }
    }
  }

  void _updateWatchProgress() {
    if (_totalDuration > 0) {
      ref
          .read(watchProgressProvider.notifier)
          .updateProgress(
            WatchProgress(
              animeId: widget.animeId,
              episodeId: _currentEpisodeId,
              episodeNumber: _currentEpisodeId,
              watchedDuration: Duration(milliseconds: _currentPosition.toInt()),
              totalDuration: Duration(milliseconds: _totalDuration.toInt()),
              lastWatchedAt: DateTime.now(),
            ),
          );
    }
  }

  void _onEpisodeFinished() {
    HapticFeedback.mediumImpact();
    // Check if there's a next episode
    final episodes = MockData.getEpisodesForAnime(widget.animeId);
    final currentIndex = episodes.indexWhere((e) => e.id == _currentEpisodeId);
    if (currentIndex < episodes.length - 1) {
      // Play next episode
      _playEpisode(episodes[currentIndex + 1]);
    }
  }

  void _playEpisode(Episode episode) {
    setState(() {
      _currentEpisodeId = episode.id;
      _currentPosition = 0;
      _isInitialized = false;
    });
    _disposeControllers();
    _initializePlayer();
  }

  void _disposeControllers() {
    _videoController?.removeListener(_onVideoUpdate);
    _chewieController?.dispose();
    _videoController?.dispose();
    _videoController = null;
    _chewieController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Show system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() => _showControls = !_showControls);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            if (_isInitialized && _chewieController != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              )
            else
              _buildLoadingState(),

            // Custom top overlay with info
            if (_showControls) _buildTopOverlay(),

            // Buffering indicator
            if (_isBuffering)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final anime = MockData.getAnimeById(widget.animeId);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (anime != null)
          CachedNetworkImage(imageUrl: anime.posterUrl, fit: BoxFit.cover),
        Container(color: Colors.black54),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 16),
              Text('Loading episode...', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    final anime = MockData.getAnimeById(widget.animeId);
    if (anime == null) return Container(color: Colors.black);

    return CachedNetworkImage(imageUrl: anime.posterUrl, fit: BoxFit.cover);
  }

  Widget _buildTopOverlay() {
    final anime = MockData.getAnimeById(widget.animeId);
    final episode = MockData.getEpisodeById(widget.animeId, _currentEpisodeId);
    final episodes = MockData.getEpisodesForAnime(widget.animeId);
    final currentIndex = episodes.indexWhere((e) => e.id == _currentEpisodeId);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < episodes.length - 1;

    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: AppConstants.animationFast,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime?.displayTitle ?? 'Unknown',
                        style: AppTypography.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Episode ${episode?.number}: ${episode?.title ?? ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Previous episode
                if (hasPrevious)
                  IconButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _playEpisode(episodes[currentIndex - 1]);
                    },
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Previous Episode',
                  ),
                // Next episode
                if (hasNext)
                  IconButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _playEpisode(episodes[currentIndex + 1]);
                    },
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Next Episode',
                  ),
                // Episode list
                IconButton(
                  onPressed: () => _showEpisodeList(episodes, currentIndex),
                  icon: const Icon(
                    Icons.playlist_play_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Episodes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEpisodeList(List<Episode> episodes, int currentIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Episodes', style: AppTypography.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final ep = episodes[index];
                  final isPlaying = ep.id == _currentEpisodeId;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? AppColors.primaryPurple
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: isPlaying
                            ? const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${ep.number}',
                                style: AppTypography.labelMedium,
                              ),
                      ),
                    ),
                    title: Text(
                      ep.title.isNotEmpty ? ep.title : 'Episode ${ep.number}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isPlaying ? AppColors.primaryPurple : null,
                      ),
                    ),
                    subtitle: Text(
                      _formatDuration(ep.duration),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!isPlaying) {
                        _playEpisode(ep);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
          Text('Playback Error', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _disposeControllers();
              _initializePlayer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
