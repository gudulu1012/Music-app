import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

/// Library screen — hub for favorites, playlists, downloads, history.
class LibraryScreen extends StatelessWidget {
  final VoidCallback? onNavigateToFavorites;
  final VoidCallback? onNavigateToRecentlyPlayed;
  final VoidCallback? onNavigateToDownloads;
  final VoidCallback? onNavigateToPlaylists;

  const LibraryScreen({
    super.key,
    this.onNavigateToFavorites,
    this.onNavigateToRecentlyPlayed,
    this.onNavigateToDownloads,
    this.onNavigateToPlaylists,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = Responsive.value(context, mobile: 2, tablet: 3, desktop: 4);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Your Library', style: theme.textTheme.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () {}, // TODO: Create playlist
                tooltip: 'Create Playlist',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Library sections grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildListDelegate([
                _LibraryCard(
                  icon: Icons.favorite_rounded,
                  title: 'Favorites',
                  subtitle: 'Songs you love',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                  ),
                  onTap: onNavigateToFavorites,
                ),
                _LibraryCard(
                  icon: Icons.history_rounded,
                  title: 'Recently Played',
                  subtitle: 'Your history',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  onTap: onNavigateToRecentlyPlayed,
                ),
                _LibraryCard(
                  icon: Icons.download_rounded,
                  title: 'Downloads',
                  subtitle: 'Offline music',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                  ),
                  onTap: onNavigateToDownloads,
                ),
                _LibraryCard(
                  icon: Icons.queue_music_rounded,
                  title: 'Playlists',
                  subtitle: 'Your collections',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  onTap: onNavigateToPlaylists,
                ),
              ]),
            ),
          ),

          // Playlists section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Playlists', style: theme.textTheme.headlineMedium),
                  TextButton.icon(
                    onPressed: () {}, // TODO: Create playlist
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New'),
                  ),
                ],
              ),
            ),
          ),

          // Empty playlists placeholder
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.playlist_add_rounded,
                        size: 48, color: AppTheme.darkTextTertiary),
                    const SizedBox(height: 12),
                    Text(
                      'Create your first playlist',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organize your favorite songs',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Create Playlist'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _LibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
