import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../app/theme/app_theme.dart';

/// Persistent mini-player bar shown at the bottom of the app shell.
///
/// Displays current song info, artwork, play/pause, and a progress indicator.
/// Tapping it navigates to the full NowPlayingScreen.
class MiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;

    if (song == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
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
            // Progress bar
            LinearProgressIndicator(
              value: audioManager.progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPurple),
              minHeight: 2,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Artwork
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
                                ),
                              )
                            : const Icon(
                                Icons.music_note_rounded,
                                color: AppTheme.darkTextTertiary,
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
                          Text(
                            song.artist,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Play/pause
                    IconButton(
                      onPressed: audioManager.togglePlayPause,
                      icon: Icon(
                        audioManager.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    // Next
                    IconButton(
                      onPressed:
                          audioManager.hasNext ? audioManager.next : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: audioManager.hasNext
                            ? Colors.white
                            : AppTheme.darkTextTertiary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
