import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../app/router.dart';
import 'glass_container.dart';

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
      Navigator.of(context, rootNavigator: true)
          .pushNamed(AppRouter.nowPlaying);
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
    final accent = theme.colorScheme.primary;
    final progressValue = audioManager.progress.clamp(0.0, 1.0);

    return Semantics(
      label: 'Mini Player: ${song.title} by ${song.artist}',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: GlassContainer(
            height: 64,
            borderRadius: BorderRadius.circular(16),
            blur: 20,
            backgroundColor: const Color(0xE515151A),
            borderColor: Colors.white.withAlpha(24),
            borderWidth: 1.0,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(90),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white.withAlpha(15),
                  valueColor: AlwaysStoppedAnimation(accent),
                  minHeight: 2,
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
                            color: SonoraColors.surfaceElevated,
                            child: song.artworkUrl.isNotEmpty
                                ? Image.network(
                                    song.artworkUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.music_note_rounded,
                                      color: SonoraColors.textTertiary,
                                      size: 22,
                                    ),
                                  )
                                : const Icon(
                                    Icons.music_note_rounded,
                                    color: SonoraColors.textTertiary,
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
                                audioManager.playbackState ==
                                        PlaybackState.error
                                    ? 'Error playing track'
                                    : song.artist,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: audioManager.playbackState ==
                                          PlaybackState.error
                                      ? SonoraColors.error
                                      : SonoraColors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Play/Pause/Loading/Error Control
                        _buildPlaybackButton(audioManager, accent),
                        // Next Track Button
                        IconButton(
                          tooltip: 'Next track',
                          onPressed:
                              audioManager.hasNext ? audioManager.next : null,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: audioManager.hasNext
                                ? SonoraColors.textPrimary
                                : SonoraColors.textTertiary,
                            size: 26,
                          ),
                        ),
                        // Queue button
                        IconButton(
                          tooltip: 'Queue',
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed(AppRouter.queue);
                          },
                          icon: const Icon(
                            Icons.queue_music_rounded,
                            color: SonoraColors.textSecondary,
                            size: 22,
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
      ),
    );
  }

  Widget _buildPlaybackButton(AudioManager audioManager, Color accent) {
    if (audioManager.playbackState == PlaybackState.loading) {
      return SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
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
          color: SonoraColors.error,
          size: 26,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: audioManager.isPlaying ? 'Pause' : 'Play',
        onPressed: audioManager.togglePlayPause,
        padding: EdgeInsets.zero,
        icon: Icon(
          audioManager.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
