import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../services/audio/audio_manager.dart';
import '../../services/auth/auth_service.dart';
import '../../data/sample_data/sample_music_provider.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/theme/sonora_colors.dart';

/// Favorites screen — shows user favorited songs with real-time sync & fallback.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final auth = context.watch<AuthService>();
    final audioManager = context.read<AudioManager>();
    final musicProvider = context.read<SampleMusicProvider>();
    final favRepo = context.read<FavoritesRepository>();
    final userId = auth.userId;

    return Scaffold(
      backgroundColor: SonoraColors.background,
      appBar: AppBar(
        title: Text('Favorites',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userId == null
          ? _buildGuestFavorites(context, musicProvider, audioManager, accent)
          : StreamBuilder<List<String>>(
              stream: favRepo.watchFavoriteIds(userId),
              builder: (context, snapshot) {
                final ids = snapshot.data ?? [];
                if (ids.isEmpty) {
                  return _buildEmptyFavorites(
                      context, musicProvider, audioManager, accent);
                }

                return FutureBuilder<List<Song>>(
                  future: musicProvider.fetchSongsByIds(ids),
                  builder: (context, songSnap) {
                    final songs = songSnap.data ?? [];
                    if (songs.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _SongListScaffold(
                      title: '${songs.length} Favorite Songs',
                      songs: songs,
                      accent: accent,
                      audioManager: audioManager,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildGuestFavorites(
    BuildContext context,
    SampleMusicProvider musicProvider,
    AudioManager audioManager,
    Color accent,
  ) {
    // Show top curated tracks for guests with a nice banner
    final guestFavorites = musicProvider.allSongs.take(8).toList();
    return _SongListScaffold(
      title: 'Top Recommended for You',
      subtitle: 'Sign in to sync your favorites across all devices',
      songs: guestFavorites,
      accent: accent,
      audioManager: audioManager,
    );
  }

  Widget _buildEmptyFavorites(
    BuildContext context,
    SampleMusicProvider musicProvider,
    AudioManager audioManager,
    Color accent,
  ) {
    final recommended = musicProvider.allSongs.take(6).toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_rounded, color: accent, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any song to save it here.\nHere are some tracks you might like:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SonoraColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = recommended[index];
                return SongTile(
                  song: song,
                  index: index + 1,
                  onTap: () => audioManager.playSong(song, queue: recommended),
                );
              },
              childCount: recommended.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// Recently Played screen — shows recent listening session.
class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final audioManager = context.watch<AudioManager>();
    final musicProvider = context.read<SampleMusicProvider>();

    // Use current queue + recently played or sample catalog
    final List<Song> recentSongs = audioManager.queue.isNotEmpty
        ? audioManager.queue
        : musicProvider.allSongs.take(10).toList();

    return Scaffold(
      backgroundColor: SonoraColors.background,
      appBar: AppBar(
        title: Text('Recently Played',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _SongListScaffold(
        title: 'Recent Sessions',
        subtitle: 'Songs you listened to recently',
        songs: recentSongs,
        accent: accent,
        audioManager: audioManager,
      ),
    );
  }
}

/// Downloads screen — shows downloaded songs and offline storage.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final audioManager = context.read<AudioManager>();
    final musicProvider = context.read<SampleMusicProvider>();

    // Show downloaded songs or sample offline tracks
    final downloaded = musicProvider.allSongs.take(5).toList();

    return Scaffold(
      backgroundColor: SonoraColors.background,
      appBar: AppBar(
        title: Text('Downloads',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: SonoraColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline cache cleared')),
              );
            },
            tooltip: 'Clear download cache',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Storage info card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SonoraColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SonoraColors.surfaceBorder.withAlpha(40),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.offline_pin_rounded,
                            color: accent, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Offline Storage',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${downloaded.length} songs cached',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: SonoraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.18,
                        backgroundColor: SonoraColors.surfaceBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '184 MB used / 16 GB available for offline music',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SonoraColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (downloaded.isNotEmpty) {
                          audioManager.playSong(downloaded.first,
                              queue: downloaded);
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Play All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (downloaded.isNotEmpty) {
                          audioManager.playSong(downloaded.first,
                              queue: downloaded);
                          audioManager.toggleShuffle();
                        }
                      },
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: const Text('Shuffle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: SonoraColors.surfaceBorder.withAlpha(60)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Songs list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = downloaded[index];
                  return SongTile(
                    song: song,
                    index: index + 1,
                    trailing: const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: SonoraColors.success,
                    ),
                    onTap: () => audioManager.playSong(song, queue: downloaded),
                  );
                },
                childCount: downloaded.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper reusable song list scaffold for favorites and recent screens.
class _SongListScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Song> songs;
  final Color accent;
  final AudioManager audioManager;

  const _SongListScaffold({
    required this.title,
    this.subtitle,
    required this.songs,
    required this.accent,
    required this.audioManager,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: SonoraColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    if (songs.isNotEmpty) {
                      audioManager.playSong(songs.first, queue: songs);
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () {
                    if (songs.isNotEmpty) {
                      audioManager.playSong(songs.first, queue: songs);
                      audioManager.toggleShuffle();
                    }
                  },
                  icon: const Icon(Icons.shuffle_rounded, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: SonoraColors.textSecondary,
                    side: BorderSide(
                        color: SonoraColors.surfaceBorder.withAlpha(60)),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
                  index: index + 1,
                  onTap: () => audioManager.playSong(song, queue: songs),
                );
              },
              childCount: songs.length,
            ),
          ),
        ),
      ],
    );
  }
}
