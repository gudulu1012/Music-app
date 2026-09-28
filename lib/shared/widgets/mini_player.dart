import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router.dart';

/// Persistent mini-player bar shown at the bottom of the app shell.
///
/// Displays current song info, artwork, playback progress, and controls.
/// Reacts to all [AudioManager] playback states (idle, loading, playing, paused, error).
/// Tapping it navigates to the full [NowPlayingScreen].
class MiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      Navigator.of(context, rootNavigator: true).pushNamed(AppRouter.nowPlaying);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;

    // Gracefully hide when no song is active or state is idle with no song
    if (!audioManager.hasSong || song == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final progressValue = audioManager.progress.clamp(0.0, 1.0);

    return Semantics(
      label: 'Mini Player: ${song.title} by ${song.artist}',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(context),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            border: Border(
              top: BorderSide(
                color: AppTheme.darkElevated.withAlpha(128),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar across the top of the mini-player
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: AppTheme.darkElevated.withAlpha(80),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPurple),
                minHeight: 2.5,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Artwork with fallback
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 44,
                          color: AppTheme.darkElevated,
                          child: song.artworkUrl.isNotEmpty
                              ? Image.network(
                                  song.artworkUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.music_note_rounded,
                                    color: AppTheme.darkTextTertiary,
                                    size: 22,
                                  ),
                                )
                              : const Icon(
                                  Icons.music_note_rounded,
                                  color: AppTheme.darkTextTertiary,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Song info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song.title,
                              style: theme.textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              audioManager.playbackState == PlaybackState.error
                                  ? 'Error playing track'
                                  : song.artist,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: audioManager.playbackState == PlaybackState.error
                                    ? const Color(0xFFEF4444)
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play/Pause/Loading/Error Control
                      _buildPlaybackButton(audioManager),
                      // Next Track Button
                      IconButton(
                        tooltip: 'Next track',
                        onPressed: audioManager.hasNext ? audioManager.next : null,
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: audioManager.hasNext
                              ? Colors.white
                              : AppTheme.darkTextTertiary,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackButton(AudioManager audioManager) {
    if (audioManager.playbackState == PlaybackState.loading) {
      return const SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
          ),
        ),
      );
    }

    if (audioManager.playbackState == PlaybackState.error) {
      return IconButton(
        tooltip: 'Playback error - Retry',
        onPressed: audioManager.togglePlayPause,
        icon: const Icon(
          Icons.refresh_rounded,
          color: Color(0xFFEF4444),
          size: 26,
        ),
      );
    }

    return IconButton(
      tooltip: audioManager.isPlaying ? 'Pause' : 'Play',
      onPressed: audioManager.togglePlayPause,
      icon: Icon(
        audioManager.isPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
