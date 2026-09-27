import 'package:flutter/material.dart';
import '../../shared/widgets/widgets.dart';

/// Favorites screen — shows all favorited songs.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: theme.textTheme.headlineMedium),
      ),
      body: const EmptyState(
        icon: Icons.favorite_outline_rounded,
        title: 'No favorites yet',
        subtitle: 'Tap the heart icon on any song to add it here',
      ),
    );
  }
}

/// Recently Played screen — shows listening history.
class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Recently Played', style: theme.textTheme.headlineMedium),
      ),
      body: const EmptyState(
        icon: Icons.history_rounded,
        title: 'No listening history',
        subtitle: 'Songs you play will appear here',
      ),
    );
  }
}

/// Downloads screen — shows downloaded songs.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloads', style: theme.textTheme.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {},
            tooltip: 'Clear all downloads',
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.download_done_rounded,
        title: 'No downloads',
        subtitle: 'Download songs for offline listening',
      ),
    );
  }
}
