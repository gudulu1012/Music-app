import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// A card for displaying an album or playlist in a grid.
class ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;
  final double width;
  final bool isCircular; // For artist cards

  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.width = 160,
    this.isCircular = false,
  });

  /// Album card variant.
  const ContentCard.album({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.width = 160,
  }) : isCircular = false;

  /// Artist card variant (circular image).
  const ContentCard.artist({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.imageUrl,
    this.onTap,
    this.width = 140,
  }) : isCircular = true;

  /// Playlist card variant.
  const ContentCard.playlist({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.width = 160,
  }) : isCircular = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(isCircular ? width : 12),
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(isCircular ? width : 12),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.darkElevated,
      child: Icon(
        isCircular ? Icons.person_rounded : Icons.album_rounded,
        size: width * 0.3,
        color: AppTheme.darkTextTertiary,
      ),
    );
  }
}
