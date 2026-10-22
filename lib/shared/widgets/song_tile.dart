import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../shared/theme/sonora_colors.dart';

/// A single song row used in lists throughout the app.
///
/// Shows artwork, title, artist, duration, and optional trailing actions.
/// Uses accent color from the theme for the currently-playing indicator.
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;
  final Widget? trailing;
  final bool isPlaying;
  final bool showArtwork;
  final int? index;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMorePressed,
    this.trailing,
    this.isPlaying = false,
    this.showArtwork = true,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isPlaying
            ? BoxDecoration(
                color: accent.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            // Index or artwork
            if (index != null) ...[
              SizedBox(
                width: 28,
                child: Text(
                  '${index!}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isPlaying ? accent : SonoraColors.textTertiary,
                    fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (showArtwork) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: SonoraColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: song.artworkUrl.isNotEmpty
                      ? Image.network(
                          song.artworkUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _artworkPlaceholder(),
                        )
                      : _artworkPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
            ],
            // Title and artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isPlaying ? accent : null,
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SonoraColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Trailing widget or more button
            if (trailing != null)
              trailing!
            else if (onMorePressed != null)
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18),
                onPressed: onMorePressed,
                visualDensity: VisualDensity.compact,
                color: SonoraColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      color: SonoraColors.surfaceElevated,
      child: const Icon(Icons.music_note_rounded,
          size: 22, color: SonoraColors.textTertiary),
    );
  }
}
