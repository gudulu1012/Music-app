import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../core/utils/format_utils.dart';

/// Desktop right-side panel showing Now Playing details and Queue.
///
/// Matches the reference design with:
/// - Large artwork
/// - Song info (title, artist, favorite)
/// - Progress bar with timestamps
/// - Playback controls (shuffle, prev, play/pause, next, repeat)
/// - Secondary controls (lyrics, queue, devices, share)
/// - Queue list with Now Playing and Up Next sections
///
/// All playback controls are connected to the existing [AudioManager].
class DesktopSidePlayer extends StatefulWidget {
  final VoidCallback? onClose;

  const DesktopSidePlayer({super.key, this.onClose});

  @override
  State<DesktopSidePlayer> createState() => _DesktopSidePlayerState();
}

class _DesktopSidePlayerState extends State<DesktopSidePlayer> {
  bool _showQueue = true;

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    if (song == null) {
      return Container(
        width: 320,
        margin: const EdgeInsets.fromLTRB(8, 12, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF130912).withAlpha(220),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Colors.white.withAlpha(24),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 28,
              offset: const Offset(-4, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note_rounded,
                    size: 48, color: SonoraColors.textTertiary),
                SizedBox(height: 12),
                Text(
                  'No track playing',
                  style: TextStyle(color: SonoraColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 320,
      height: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF130912).withAlpha(225),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: accent.withAlpha(45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(140),
            blurRadius: 28,
            offset: const Offset(-4, 6),
          ),
          BoxShadow(
            color: accent.withAlpha(25),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final artworkSize = availableHeight < 700
                  ? 120.0
                  : (availableHeight < 800 ? 148.0 : 178.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Now Playing header ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                    child: Row(
                      children: [
                        Text(
                          'Now Playing',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_vert,
                              size: 18, color: SonoraColors.textSecondary),
                          onPressed: () {},
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),

                  // ─── Artwork ──────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Center(
                      child: Container(
                        width: artworkSize,
                        height: artworkSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(30),
                              blurRadius: 26,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.black.withAlpha(80),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
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
                  ),

                  const SizedBox(height: 8),

                  // ─── Song Info ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: SonoraColors.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border_rounded,
                              size: 20),
                          onPressed: () {},
                          color: SonoraColors.textSecondary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ─── Progress bar ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10),
                          ),
                          child: Slider(
                            value: audioManager.progress.clamp(0.0, 1.0),
                            onChanged: (value) {
                              final newPosition = Duration(
                                milliseconds: (value *
                                        audioManager.duration.inMilliseconds)
                                    .round(),
                              );
                              audioManager.seek(newPosition);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                FormatUtils.duration(audioManager.position),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: SonoraColors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                FormatUtils.duration(audioManager.duration),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: SonoraColors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ─── Playback Controls ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SidePlayerButton(
                        icon: Icons.shuffle_rounded,
                        isActive: audioManager.shuffleEnabled,
                        accent: accent,
                        onPressed: audioManager.toggleShuffle,
                        tooltip: 'Shuffle',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 26),
                        onPressed: audioManager.previous,
                        color: SonoraColors.textPrimary,
                      ),
                      const SizedBox(width: 2),
                      GestureDetector(
                        onTap: audioManager.togglePlayPause,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withAlpha(60),
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
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 26),
                        onPressed: audioManager.next,
                        color: SonoraColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      _SidePlayerButton(
                        icon: audioManager.repeatMode == RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        isActive: audioManager.repeatMode != RepeatMode.off,
                        accent: accent,
                        onPressed: audioManager.cycleRepeatMode,
                        tooltip: 'Repeat',
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // ─── Secondary Controls ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SidePlayerButton(
                        icon: Icons.lyrics_outlined,
                        onPressed: () {},
                        tooltip: 'Lyrics',
                      ),
                      _SidePlayerButton(
                        icon: Icons.queue_music_rounded,
                        isActive: _showQueue,
                        accent: accent,
                        onPressed: () {
                          setState(() => _showQueue = !_showQueue);
                        },
                        tooltip: 'Queue',
                      ),
                      _SidePlayerButton(
                        icon: Icons.devices_rounded,
                        onPressed: () {},
                        tooltip: 'Devices',
                      ),
                      _SidePlayerButton(
                        icon: Icons.share_rounded,
                        onPressed: () {},
                        tooltip: 'Share',
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ─── Queue Section ─────────────────────────────
                  if (_showQueue) ...[
                    Container(
                      height: 0.5,
                      color: SonoraColors.surfaceBorder.withAlpha(60),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 2),
                      child: Row(
                        children: [
                          Text(
                            'Queue',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${audioManager.queue.length})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SonoraColors.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: audioManager.clearQueue,
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Text(
                              'Clear',
                              style: TextStyle(color: accent, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Queue tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _QueueTab(
                            label: 'Now Playing',
                            isSelected: true,
                            accent: accent,
                          ),
                          const SizedBox(width: 8),
                          _QueueTab(
                            label: 'Up Next',
                            isSelected: false,
                            accent: accent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Queue list with drag-and-drop reordering
                    Expanded(
                      child: audioManager.queue.isEmpty
                          ? const Center(
                              child: Text(
                                'Queue is empty',
                                style:
                                    TextStyle(color: SonoraColors.textTertiary),
                              ),
                            )
                          : ReorderableListView.builder(
                              buildDefaultDragHandles: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: audioManager.queue.length,
                              // ignore: deprecated_member_use
                              onReorder: audioManager.reorderQueue,
                              proxyDecorator: (child, index, animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    final t = Curves.easeInOut
                                        .transform(animation.value);
                                    return Material(
                                      color: Colors.transparent,
                                      elevation: 6 * t,
                                      shadowColor: Colors.black.withAlpha(160),
                                      child: child,
                                    );
                                  },
                                  child: child,
                                );
                              },
                              itemBuilder: (context, index) {
                                final queueSong = audioManager.queue[index];
                                final isCurrent =
                                    index == audioManager.currentIndex;
                                return _QueueItem(
                                  key:
                                      ValueKey('side_q_${queueSong.id}_$index'),
                                  song: queueSong,
                                  index: index,
                                  isCurrent: isCurrent,
                                  accent: accent,
                                  onTap: () => audioManager.skipToIndex(index),
                                  onRemove: isCurrent
                                      ? null
                                      : () =>
                                          audioManager.removeFromQueue(index),
                                );
                              },
                            ),
                    ),
                  ] else
                    const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      color: SonoraColors.surfaceElevated,
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 48,
          color: SonoraColors.textTertiary,
        ),
      ),
    );
  }
}

// ─── Side Player Button ───────────────────────────────────────

class _SidePlayerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool isActive;
  final Color? accent;

  const _SidePlayerButton({
    required this.icon,
    this.onPressed,
    this.tooltip = '',
    this.isActive = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color: isActive
            ? (accent ?? Theme.of(context).colorScheme.primary)
            : SonoraColors.textSecondary,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ─── Queue Tab ────────────────────────────────────────────────

class _QueueTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accent;

  const _QueueTab({
    required this.label,
    required this.isSelected,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? accent : SonoraColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? accent : SonoraColors.surfaceBorder.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : SonoraColors.textSecondary,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── Queue Item ───────────────────────────────────────────────

class _QueueItem extends StatelessWidget {
  final dynamic song;
  final int index;
  final bool isCurrent;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _QueueItem({
    super.key,
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.accent,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: isCurrent
          ? BoxDecoration(
              color: accent.withAlpha(16),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Row(
        children: [
          // Index & Artwork & Metadata clickable area for song selection
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    // Index
                    SizedBox(
                      width: 18,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCurrent ? accent : SonoraColors.textTertiary,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Artwork
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 34,
                        height: 34,
                        color: SonoraColors.surfaceElevated,
                        child: (song.artworkUrl != null &&
                                (song.artworkUrl as String).isNotEmpty)
                            ? Image.network(
                                song.artworkUrl as String,
                                fit: BoxFit.cover,
                                cacheWidth: 80,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.music_note_rounded,
                                  size: 16,
                                  color: SonoraColors.textTertiary,
                                ),
                              )
                            : const Icon(
                                Icons.music_note_rounded,
                                size: 16,
                                color: SonoraColors.textTertiary,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isCurrent ? accent : SonoraColors.textPrimary,
                              fontWeight:
                                  isCurrent ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SonoraColors.textTertiary,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // More/Remove button
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 14),
              onPressed: onRemove,
              color: SonoraColors.textTertiary,
              tooltip: 'Remove',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              padding: EdgeInsets.zero,
            ),
          // Reorder drag handle
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Tooltip(
                message: 'Drag to reorder',
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Icon(
                    Icons.drag_handle_rounded,
                    size: 16,
                    color: isCurrent
                        ? accent.withAlpha(180)
                        : SonoraColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
