import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../app/theme/app_theme.dart';

/// A single song row used in lists throughout the app.
///
/// Shows artwork, title, artist, duration, and optional trailing actions.
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Index or artwork
            if (index != null) ...[
              SizedBox(
                width: 32,
                child: Text(
                  '${index!}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isPlaying
                        ? AppTheme.primaryPurple
                        : null,
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: song.artworkUrl.isNotEmpty
                      ? Image.network(
                          song.artworkUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _artworkPlaceholder(theme),
                        )
                      : _artworkPlaceholder(theme),
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
                      color: isPlaying ? AppTheme.primaryPurple : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Duration
            Text(
              song.formattedDuration,
              style: theme.textTheme.bodySmall,
            ),
            // Trailing widget or more button
            if (trailing != null) trailing!
            else if (onMorePressed != null)
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: onMorePressed,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }

  Widget _artworkPlaceholder(ThemeData theme) {
    return Container(
      color: AppTheme.darkElevated,
      child: const Icon(Icons.music_note_rounded, size: 24, color: AppTheme.darkTextTertiary),
    );
  }
}
