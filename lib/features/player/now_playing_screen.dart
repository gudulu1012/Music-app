import 'dart:math';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../shared/widgets/widgets.dart';

/// Full-screen Now Playing screen.
///
/// Shows large artwork, song info, seeking slider, playback controls,
/// volume slider, bottom actions, and access to the playback queue.
/// Directly wired to [AudioManager] state and methods.
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  double? _dragValue;
  bool _showVolumeSlider = false;

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;
    final theme = Theme.of(context);

    // Graceful handling of no-song state
    if (!audioManager.hasSong || song == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: EmptyState(
            icon: Icons.music_off_rounded,
            title: 'No Song Playing',
            subtitle: 'Choose a song from Home, Search, or Library to start playing.',
            action: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Browsing'),
            ),
          ),
        ),
      );
    }

    final canPrevious = audioManager.hasPrevious ||
        audioManager.position.inSeconds > 0 ||
        audioManager.repeatMode == RepeatMode.all;

    final canNext = audioManager.hasNext ||
        audioManager.repeatMode == RepeatMode.all;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          tooltip: 'Minimize',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            tooltip: 'Queue',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QueueScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _showVolumeSlider ? Icons.volume_up_rounded : Icons.volume_down_rounded,
              color: _showVolumeSlider ? AppTheme.primaryPurple : AppTheme.darkTextSecondary,
            ),
            tooltip: 'Volume Control',
            onPressed: () {
              setState(() {
                _showVolumeSlider = !_showVolumeSlider;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryPurple.withAlpha(60),
              AppTheme.darkBackground,
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive artwork size constrained to screen space
              final maxArtSize = min(constraints.maxWidth * 0.75, constraints.maxHeight * 0.42);
              final artworkSize = maxArtSize.clamp(180.0, 320.0);

              final currentPos = _dragValue != null
                  ? Duration(
                      milliseconds:
                          (_dragValue! * audioManager.duration.inMilliseconds).round(),
                    )
                  : audioManager.position;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // ─── Artwork ──────────────────────────────────
                        Center(
                          child: Container(
                            width: artworkSize,
                            height: artworkSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withAlpha(60),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: song.artworkUrl.isNotEmpty
                                  ? Image.network(
                                      song.artworkUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _artworkPlaceholder(),
                                    )
                                  : _artworkPlaceholder(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ─── Song Info ────────────────────────────────
                        Text(
                          song.title,
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${song.artist} • ${song.album}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Error Banner if playback failed
                        if (audioManager.playbackState == PlaybackState.error) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withAlpha(80),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 18, color: Color(0xFFEF4444)),
                                const SizedBox(width: 8),
                                Text(
                                  'Error playing track. Tap play to retry.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // ─── Optional Volume Slider ───────────────────
                        if (_showVolumeSlider) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.volume_mute_rounded,
                                    size: 18, color: AppTheme.darkTextSecondary),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 5,
                                      ),
                                    ),
                                    child: Slider(
                                      value: audioManager.volume,
                                      onChanged: (v) => audioManager.setVolume(v),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.volume_up_rounded,
                                    size: 18, color: AppTheme.darkTextSecondary),
                              ],
                            ),
                          ),
                        ],

                        // ─── Progress Slider ──────────────────────────
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: AppTheme.primaryPurple,
                            inactiveTrackColor: AppTheme.darkElevated,
                            thumbColor: Colors.white,
                            overlayColor: AppTheme.primaryPurple.withAlpha(30),
                            thumbShape:
                                const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: (_dragValue ?? audioManager.progress).clamp(0.0, 1.0),
                            onChanged: (value) {
                              setState(() {
                                _dragValue = value;
                              });
                            },
                            onChangeEnd: (value) {
                              final newPos = Duration(
                                milliseconds:
                                    (value * audioManager.duration.inMilliseconds).round(),
                              );
                              audioManager.seek(newPos);
                              setState(() {
                                _dragValue = null;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                FormatUtils.duration(currentPos),
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                FormatUtils.duration(audioManager.duration),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ─── Playback Controls ────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Shuffle Button
                            IconButton(
                              tooltip: audioManager.shuffleEnabled
                                  ? 'Shuffle: On'
                                  : 'Shuffle: Off',
                              onPressed: audioManager.toggleShuffle,
                              icon: Icon(
                                Icons.shuffle_rounded,
                                color: audioManager.shuffleEnabled
                                    ? AppTheme.primaryPurple
                                    : AppTheme.darkTextSecondary,
                                size: 24,
                              ),
                            ),
                            // Previous Button
                            IconButton(
                              tooltip: 'Previous track',
                              onPressed: canPrevious ? audioManager.previous : null,
                              icon: Icon(
                                Icons.skip_previous_rounded,
                                size: 36,
                                color: canPrevious
                                    ? Colors.white
                                    : AppTheme.darkTextTertiary,
                              ),
                            ),
                            // Play/Pause/Loading Button
                            _buildPlayPauseButton(audioManager),
                            // Next Button
                            IconButton(
                              tooltip: 'Next track',
                              onPressed: canNext ? audioManager.next : null,
                              icon: Icon(
                                Icons.skip_next_rounded,
                                size: 36,
                                color: canNext
                                    ? Colors.white
                                    : AppTheme.darkTextTertiary,
                              ),
                            ),
                            // Repeat Button
                            _buildRepeatButton(audioManager),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ─── Bottom Actions ───────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              tooltip: 'Favorite',
                              icon: const Icon(Icons.favorite_border_rounded),
                              onPressed: () {},
                              color: AppTheme.darkTextSecondary,
                            ),
                            IconButton(
                              tooltip: 'Add to Playlist',
                              icon: const Icon(Icons.playlist_add_rounded),
                              onPressed: () {},
                              color: AppTheme.darkTextSecondary,
                            ),
                            IconButton(
                              tooltip: 'Download',
                              icon: const Icon(Icons.download_outlined),
                              onPressed: () {},
                              color: AppTheme.darkTextSecondary,
                            ),
                            IconButton(
                              tooltip: 'Share',
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () {},
                              color: AppTheme.darkTextSecondary,
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(AudioManager audioManager) {
    if (audioManager.playbackState == PlaybackState.loading) {
      return Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
        ),
        child: const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (audioManager.playbackState == PlaybackState.error) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEF4444).withAlpha(180),
        ),
        child: IconButton(
          tooltip: 'Playback error - Tap to retry',
          onPressed: audioManager.togglePlayPause,
          icon: const Icon(
            Icons.refresh_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
      ),
      child: IconButton(
        tooltip: audioManager.isPlaying ? 'Pause' : 'Play',
        onPressed: audioManager.togglePlayPause,
        icon: Icon(
          audioManager.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          size: 34,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRepeatButton(AudioManager audioManager) {
    IconData icon;
    Color color;
    String tooltip;

    switch (audioManager.repeatMode) {
      case RepeatMode.off:
        icon = Icons.repeat_rounded;
        color = AppTheme.darkTextSecondary;
        tooltip = 'Repeat: Off';
        break;
      case RepeatMode.all:
        icon = Icons.repeat_rounded;
        color = AppTheme.primaryPurple;
        tooltip = 'Repeat: All';
        break;
      case RepeatMode.one:
        icon = Icons.repeat_one_rounded;
        color = AppTheme.primaryPurple;
        tooltip = 'Repeat: One';
        break;
    }

    return IconButton(
      tooltip: tooltip,
      onPressed: audioManager.cycleRepeatMode,
      icon: Icon(icon, color: color, size: 24),
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      color: AppTheme.darkElevated,
      child: const Icon(
        Icons.music_note_rounded,
        size: 80,
        color: AppTheme.darkTextTertiary,
      ),
    );
  }
}

/// Queue screen — view and manage the current playback queue.
///
/// Fully wired to [AudioManager] queue, reordering, removal, and clearing.
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  void _confirmClearQueue(BuildContext context, AudioManager audioManager) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkSurfaceVariant,
        title: const Text('Clear Queue'),
        content: const Text(
          'Are you sure you want to clear the playback queue? This will stop current playback.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              audioManager.clearQueue();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final theme = Theme.of(context);
    final queue = audioManager.queue;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Queue', style: theme.textTheme.headlineMedium),
            if (queue.isNotEmpty)
              Text(
                '${queue.length} ${queue.length == 1 ? 'song' : 'songs'}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          if (queue.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearQueue(context, audioManager),
              child: const Text(
                'Clear',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
        ],
      ),
      body: queue.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.queue_music_rounded,
                title: 'Queue is Empty',
                subtitle: 'Add songs from Home, Search, or Library to start a queue.',
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: queue.length,
              // ignore: deprecated_member_use
              onReorder: audioManager.reorderQueue,
              itemBuilder: (context, index) {
                final song = queue[index];
                final isCurrent = index == audioManager.currentIndex;

                return Material(
                  key: ValueKey('${song.id}_$index'),
                  color: isCurrent
                      ? AppTheme.primaryPurple.withAlpha(25)
                      : Colors.transparent,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: SizedBox(
                      width: 38,
                      child: isCurrent
                          ? Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withAlpha(40),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: AppTheme.primaryPurple,
                                size: 20,
                              ),
                            )
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.darkTextSecondary,
                                ),
                              ),
                            ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            song.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isCurrent ? AppTheme.primaryPurple : null,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NOW PLAYING',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      song.artist,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.formattedDuration,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          tooltip: 'Remove',
                          onPressed: () => audioManager.removeFromQueue(index),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4, right: 8),
                            child: Icon(
                              Icons.drag_handle_rounded,
                              size: 20,
                              color: AppTheme.darkTextTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => audioManager.skipToIndex(index),
                  ),
                );
              },
            ),
    );
  }
}
