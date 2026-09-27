import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';

/// Full-screen Now Playing screen.
///
/// Shows large artwork, playback controls, seek bar, and queue access.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;
    final theme = Theme.of(context);

    if (song == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No song playing')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QueueScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // ─── Artwork ──────────────────────────────────
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withAlpha(50),
                        blurRadius: 40,
                        spreadRadius: 10,
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

                const Spacer(flex: 1),

                // ─── Song Info ────────────────────────────────
                Text(
                  song.title,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${song.artist} • ${song.album}',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 24),

                // ─── Progress Slider ──────────────────────────
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: audioManager.progress.clamp(0.0, 1.0),
                    onChanged: (value) {
                      final newPos = Duration(
                        milliseconds:
                            (value * audioManager.duration.inMilliseconds)
                                .round(),
                      );
                      audioManager.seek(newPos);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FormatUtils.duration(audioManager.position),
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

                // ─── Controls ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
                    IconButton(
                      onPressed: audioManager.toggleShuffle,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: audioManager.shuffleEnabled
                            ? AppTheme.primaryPurple
                            : AppTheme.darkTextSecondary,
                      ),
                    ),
                    // Previous
                    IconButton(
                      onPressed: audioManager.previous,
                      icon: const Icon(Icons.skip_previous_rounded,
                          size: 36, color: Colors.white),
                    ),
                    // Play/Pause
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: IconButton(
                        onPressed: audioManager.togglePlayPause,
                        icon: Icon(
                          audioManager.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Next
                    IconButton(
                      onPressed: audioManager.next,
                      icon: const Icon(Icons.skip_next_rounded,
                          size: 36, color: Colors.white),
                    ),
                    // Repeat
                    IconButton(
                      onPressed: audioManager.cycleRepeatMode,
                      icon: Icon(
                        audioManager.repeatMode == RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: audioManager.repeatMode != RepeatMode.off
                            ? AppTheme.primaryPurple
                            : AppTheme.darkTextSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ─── Bottom actions ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border_rounded),
                      onPressed: () {},
                      color: AppTheme.darkTextSecondary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.playlist_add_rounded),
                      onPressed: () {},
                      color: AppTheme.darkTextSecondary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () {},
                      color: AppTheme.darkTextSecondary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {},
                      color: AppTheme.darkTextSecondary,
                    ),
                  ],
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
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

/// Queue screen — manage the current playback queue.
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final theme = Theme.of(context);
    final queue = audioManager.queue;

    return Scaffold(
      appBar: AppBar(
        title: Text('Queue', style: theme.textTheme.headlineMedium),
        actions: [
          if (queue.isNotEmpty)
            TextButton(
              onPressed: audioManager.clearQueue,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: queue.isEmpty
          ? const Center(
              child: Text('Queue is empty'),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: queue.length,
              onReorder: audioManager.reorderQueue,
              itemBuilder: (context, index) {
                final song = queue[index];
                final isCurrent = index == audioManager.currentIndex;
                return ListTile(
                  key: ValueKey('${song.id}_$index'),
                  leading: isCurrent
                      ? const Icon(Icons.play_arrow_rounded,
                          color: AppTheme.primaryPurple)
                      : Text(
                          '${index + 1}',
                          style: theme.textTheme.bodyMedium,
                        ),
                  title: Text(
                    song.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isCurrent ? AppTheme.primaryPurple : null,
                    ),
                  ),
                  subtitle: Text(song.artist, style: theme.textTheme.bodySmall),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(song.formattedDuration,
                          style: theme.textTheme.bodySmall),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () =>
                            audioManager.removeFromQueue(index),
                      ),
                      const Icon(Icons.drag_handle_rounded, size: 20),
                    ],
                  ),
                  onTap: () => audioManager.skipToIndex(index),
                );
              },
            ),
    );
  }
}
