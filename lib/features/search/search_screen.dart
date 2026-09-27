import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sample_data/sample_music_provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../models/song.dart';
import '../../shared/widgets/widgets.dart';

/// Search screen — find songs, albums, and artists.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Song> _results = [];
  bool _hasSearched = false;
  bool _isSearching = false;

  // Genre chips for quick discovery
  static const List<_GenreChip> _genres = [
    _GenreChip('Electronic', Icons.electric_bolt_rounded, Color(0xFF8B5CF6)),
    _GenreChip('Chillout', Icons.spa_rounded, Color(0xFF06B6D4)),
    _GenreChip('Hip Hop', Icons.headphones_rounded, Color(0xFFEC4899)),
    _GenreChip('Ambient', Icons.nights_stay_rounded, Color(0xFF10B981)),
    _GenreChip('Dance', Icons.music_note_rounded, Color(0xFFF59E0B)),
    _GenreChip('Acoustic', Icons.piano_rounded, Color(0xFFEF4444)),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final provider = context.read<SampleMusicProvider>();
    final results = await provider.search(query);
    if (mounted) {
      setState(() {
        _results = results;
        _hasSearched = true;
        _isSearching = false;
      });
    }
  }

  void _searchByGenre(String genre) {
    _searchController.text = genre;
    _performSearch(genre);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioManager = context.read<AudioManager>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search header
          SliverAppBar(
            floating: true,
            title: Text('Search', style: theme.textTheme.headlineMedium),
            toolbarHeight: 56,
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Songs, artists, albums...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                            _focusNode.requestFocus();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Content
          if (_isSearching)
            const SliverFillRemaining(
              child: LoadingState(message: 'Searching...'),
            )
          else if (_hasSearched && _results.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No results found',
                subtitle: 'Try a different search term',
              ),
            )
          else if (_hasSearched)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _results[index];
                  return SongTile(
                    song: song,
                    isPlaying: audioManager.currentSong?.id == song.id,
                    onTap: () =>
                        audioManager.playQueue(_results, startIndex: index),
                    onMorePressed: () {},
                  );
                },
                childCount: _results.length,
              ),
            )
          else ...[
            // Browse by genre
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Browse by Genre'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final genre = _genres[index];
                    return _GenreTile(
                      genre: genre,
                      onTap: () => _searchByGenre(genre.name),
                    );
                  },
                  childCount: _genres.length,
                ),
              ),
            ),
          ],

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _GenreChip {
  final String name;
  final IconData icon;
  final Color color;
  const _GenreChip(this.name, this.icon, this.color);
}

class _GenreTile extends StatelessWidget {
  final _GenreChip genre;
  final VoidCallback onTap;

  const _GenreTile({required this.genre, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: genre.color.withAlpha(30),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(genre.icon, color: genre.color, size: 24),
              const SizedBox(width: 12),
              Text(
                genre.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: genre.color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
