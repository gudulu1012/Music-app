import 'package:flutter/material.dart';
import '../../shared/theme/sonora_colors.dart';

/// A card for displaying an album, playlist, or artist in a horizontal list.
///
/// Features rounded corners, play overlay affordance, and hover effects on desktop.
class ContentCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;
  final double width;
  final bool isCircular; // For artist cards
  final bool showPlayButton;

  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.width = 160,
    this.isCircular = false,
    this.showPlayButton = true,
  });

  /// Album card variant.
  const ContentCard.album({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.width = 160,
    this.showPlayButton = true,
  }) : isCircular = false;

  /// Artist card variant (circular image).
  const ContentCard.artist({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.imageUrl,
    this.onTap,
    this.width = 140,
    this.showPlayButton = false,
  }) : isCircular = true;

  /// Playlist card variant.
  const ContentCard.playlist({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.width = 160,
    this.showPlayButton = true,
  }) : isCircular = false;

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with play button overlay
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: _isHovered
                        ? Matrix4.translationValues(0.0, -4.0, 0.0)
                        : Matrix4.identity(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          widget.isCircular ? widget.width : 14),
                      child: Container(
                        width: widget.width,
                        height: widget.width,
                        decoration: BoxDecoration(
                          color: SonoraColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                              widget.isCircular ? widget.width : 14),
                        ),
                        child: widget.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(),
                              )
                            : _placeholder(),
                      ),
                    ),
                  ),
                  // Play button overlay on hover
                  if (widget.showPlayButton && _isHovered && !widget.isCircular)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(80),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                widget.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SonoraColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: SonoraColors.surfaceElevated,
      child: Icon(
        widget.isCircular ? Icons.person_rounded : Icons.album_rounded,
        size: widget.width * 0.3,
        color: SonoraColors.textTertiary,
      ),
    );
  }
}
