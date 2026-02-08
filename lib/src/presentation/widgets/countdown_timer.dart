/// NYAnime Mobile - Countdown Timer Widget
///
/// Shows countdown to next episode with animated display.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/core.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final int? episodeNumber;
  final TextStyle? style;
  final bool compact;
  final VoidCallback? onComplete;

  const CountdownTimer({
    super.key,
    required this.targetDate,
    this.episodeNumber,
    this.style,
    this.compact = false,
    this.onComplete,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    if (widget.targetDate.isAfter(now)) {
      setState(() {
        _remaining = widget.targetDate.difference(now);
      });
    } else {
      _timer.cancel();
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative || _remaining == Duration.zero) {
      return const SizedBox.shrink();
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    if (widget.compact) {
      return _buildCompact(days, hours, minutes, seconds);
    }

    return _buildFull(days, hours, minutes, seconds);
  }

  Widget _buildCompact(int days, int hours, int minutes, int seconds) {
    String text;
    if (days > 0) {
      text = '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      text = '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      text = '${minutes}m ${seconds}s';
    } else {
      text = '${seconds}s';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time_rounded, size: 14, color: AppColors.primaryCyan),
        const SizedBox(width: 4),
        if (widget.episodeNumber != null)
          Text(
            'Ep ${widget.episodeNumber} in ',
            style:
                widget.style ??
                AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        Text(
          text,
          style: widget.style ?? AppTypography.countdown.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFull(int days, int hours, int minutes, int seconds) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppColors.primaryCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppColors.primaryCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Episode',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (widget.episodeNumber != null)
                    Text(
                      'Episode ${widget.episodeNumber}',
                      style: AppTypography.titleSmall,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeUnit(days, 'DAYS'),
              _buildSeparator(),
              _buildTimeUnit(hours, 'HRS'),
              _buildSeparator(),
              _buildTimeUnit(minutes, 'MIN'),
              _buildSeparator(),
              _buildTimeUnit(seconds, 'SEC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: AppTypography.countdown.copyWith(
            fontSize: 28,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Text(
      ':',
      style: AppTypography.countdown.copyWith(
        fontSize: 24,
        color: AppColors.primaryCyan,
      ),
    );
  }
}
