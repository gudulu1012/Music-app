import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../core/utils/format_utils.dart';
import 'glass_container.dart';

/// Full-featured floating desktop glass mini-player bar matching reference designs.
///
/// Features:
/// - Floating rounded frosted-glass capsule container with genuine BackdropFilter
/// - Album artwork, song title, artist, and favorite heart toggle
/// - Central track timeline slider with elapsed and remaining time
/// - Right-side playback controls (shuffle, previous, prominent play/pause, next, repeat)
/// - Interactive volume slider and expand button
class DesktopMiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onExpandPlayer;
  final VoidCallback? onToggleQueue;
  final VoidCallback? onToggleLyrics;

  const DesktopMiniPlayer({
    super.key,
    this.onTap,
    this.onExpandPlayer,
    this.onToggleQueue,
    this.onToggleLyrics,
  });

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;

    if (!audioManager.hasSong || song == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final progressValue = audioManager.progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GlassContainer(
        height: 76,
        borderRadius: BorderRadius.circular(20),
        blur: 24,
        backgroundColor: const Color(0xE0101013),
        borderColor: Colors.white.withAlpha(28),
        borderWidth: 1.0,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(140),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // ─── Left: Artwork + Title + Artist + Heart ──────────────
              SizedBox(
                width: 240,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: SonoraColors.surfaceElevated,
                          child: song.artworkUrl.isNotEmpty
                              ? Image.network(
                                  song.artworkUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _artworkPlaceholder(accent),
                                )
                              : _artworkPlaceholder(accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: SonoraColors.textTertiary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border_rounded,
                        color: SonoraColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {},
                      tooltip: 'Favorite',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // ─── Center: Time + Scrub Slider ──────────────────────────
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        FormatUtils.duration(audioManager.position),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SonoraColors.textSecondary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.5,
                          activeTrackColor: accent,
                          inactiveTrackColor: Colors.white.withAlpha(25),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5.5,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 11,
                          ),
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: progressValue,
                          onChanged: (value) {
                            final newPosition = Duration(
                              milliseconds:
                                  (value * audioManager.duration.inMilliseconds)
                                      .round(),
                            );
                            audioManager.seek(newPosition);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        FormatUtils.duration(audioManager.duration),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SonoraColors.textSecondary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // ─── Right: Controls & Volume ─────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shuffle
                  IconButton(
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: audioManager.shuffleEnabled
                          ? accent
                          : SonoraColors.textSecondary,
                      size: 19,
                    ),
                    onPressed: audioManager.toggleShuffle,
                    tooltip: 'Shuffle',
                  ),
                  // Previous
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: audioManager.previous,
                    tooltip: 'Previous',
                  ),
                  const SizedBox(width: 4),
                  // Play / Pause prominent button
                  GestureDetector(
                    onTap: audioManager.togglePlayPause,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withAlpha(80),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        audioManager.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Next
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: audioManager.next,
                    tooltip: 'Next',
                  ),
                  // Repeat
                  IconButton(
                    icon: Icon(
                      audioManager.repeatMode == RepeatMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      color: audioManager.repeatMode != RepeatMode.off
                          ? accent
                          : SonoraColors.textSecondary,
                      size: 19,
                    ),
                    onPressed: audioManager.cycleRepeatMode,
                    tooltip: 'Repeat',
                  ),

                  const SizedBox(width: 8),

                  // Volume
                  IconButton(
                    icon: Icon(
                      audioManager.volume == 0
                          ? Icons.volume_off_rounded
                          : audioManager.volume < 0.5
                              ? Icons.volume_down_rounded
                              : Icons.volume_up_rounded,
                      color: SonoraColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      audioManager
                          .setVolume(audioManager.volume == 0 ? 0.8 : 0);
                    },
                    tooltip: 'Volume',
                  ),
                  SizedBox(
                    width: 75,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        activeTrackColor: accent,
                        inactiveTrackColor: Colors.white.withAlpha(25),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 4.5,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 8,
                        ),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: audioManager.volume,
                        onChanged: (v) => audioManager.setVolume(v),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Fullscreen expand
                  IconButton(
                    icon: const Icon(
                      Icons.fullscreen_rounded,
                      color: SonoraColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onExpandPlayer ?? onTap,
                    tooltip: 'Expand Player',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artworkPlaceholder(Color accent) {
    return Container(
      color: SonoraColors.surfaceElevated,
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: accent.withAlpha(120),
          size: 24,
        ),
      ),
    );
  }
}
