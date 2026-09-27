import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sample_data/sample_music_provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../models/song.dart';
import '../../shared/widgets/widgets.dart';

/// Home screen — the main discovery surface.
///
/// Shows recently played, featured albums, quick picks, and genre sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> _catalog = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<SampleMusicProvider>();
    final catalog = await provider.fetchCatalog();
    if (mounted) {
      setState(() {
        _catalog = catalog;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioManager = context.read<AudioManager>();

    if (_isLoading) {
      return const Scaffold(
        body: LoadingState(message: 'Loading your music...'),
      );
    }

    final provider = context.read<SampleMusicProvider>();
    final albums = provider.albums;
    final greeting = _getGreeting();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: theme.textTheme.bodyMedium),
                Text('Discover Music', style: theme.textTheme.headlineMedium),
              ],
            ),
            toolbarHeight: 72,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Quick Play section
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Quick Picks',
              onSeeAllPressed: () {},
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: albums.length.clamp(0, 6),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return ContentCard.album(
                    title: album.name,
                    subtitle: album.artist,
                    imageUrl: album.artworkUrl,
                    onTap: () {
                      final songs = provider.songsByAlbum(album.name);
                      if (songs.isNotEmpty) {
                        audioManager.playQueue(songs);
                      }
                    },
                  );
                },
              ),
            ),
          ),

          // Recently Added
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recently Added',
              onSeeAllPressed: () {},
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = _catalog[index];
                return SongTile(
                  song: song,
                  isPlaying: audioManager.currentSong?.id == song.id,
                  onTap: () => audioManager.playQueue(_catalog, startIndex: index),
                  onMorePressed: () {},
                );
              },
              childCount: _catalog.length.clamp(0, 8),
            ),
          ),

          // Artists section
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Artists',
              onSeeAllPressed: () {},
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.artists.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final artist = provider.artists[index];
                  return ContentCard.artist(
                    title: artist,
                    imageUrl: 'https://picsum.photos/seed/artist$index/200/200',
                    onTap: () {
                      final songs = provider.songsByArtist(artist);
                      if (songs.isNotEmpty) {
                        audioManager.playQueue(songs);
                      }
                    },
                  );
                },
              ),
            ),
          ),

          // All Songs
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'All Songs',
              onSeeAllPressed: () {},
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = _catalog[index];
                return SongTile(
                  song: song,
                  isPlaying: audioManager.currentSong?.id == song.id,
                  onTap: () => audioManager.playQueue(_catalog, startIndex: index),
                  onMorePressed: () {},
                );
              },
              childCount: _catalog.length,
            ),
          ),

          // Bottom padding for mini player
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
