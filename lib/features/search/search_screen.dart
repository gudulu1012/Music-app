import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sample_data/sample_music_provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../models/song.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../core/responsive/responsive.dart';

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
    _GenreChip('Pop', Icons.music_note_rounded, Color(0xFFEC4899)),
    _GenreChip('Rock', Icons.electric_bolt_rounded, Color(0xFFEF4444)),
    _GenreChip('Hip Hop', Icons.headphones_rounded, Color(0xFF8B5CF6)),
    _GenreChip('R&B', Icons.graphic_eq_rounded, Color(0xFF3B82F6)),
    _GenreChip('Lo-Fi', Icons.nights_stay_rounded, Color(0xFF10B981)),
    _GenreChip('Indie', Icons.piano_rounded, Color(0xFFF59E0B)),
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
    final isDesktop = Responsive.isDesktop(context);
    final genreColumns =
        Responsive.value(context, mobile: 2, tablet: 3, desktop: 3);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header & Frosted Glass Search Bar
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  isDesktop ? 28 : 16,
                  isDesktop ? 32 : 16,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Glassmorphic Search Input
                    GlassContainer(
                      borderRadius: BorderRadius.circular(16),
                      blur: 16,
                      borderColor: Colors.white.withAlpha(35),
                      backgroundColor: Colors.white.withAlpha(12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 2),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _performSearch,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search songs, artists, genres...',
                          hintStyle: TextStyle(
                            color: Colors.white.withAlpha(120),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withAlpha(160),
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: SonoraColors.textTertiary,
                                    size: 18,
                                  ),
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
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Content
          if (_isSearching)
            const SliverFillRemaining(
              child: LoadingState(message: 'Searching your vibe...'),
            )
          else if (_hasSearched && _results.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No results found',
                subtitle: 'Try a different search term or explore genres',
              ),
            )
          else if (_hasSearched)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
              sliver: SliverList(
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
              ),
            )
          else ...[
            // Browse by genre
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                child: const SectionHeader(title: 'Browse Genres'),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: genreColumns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
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

          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
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

class _GenreTile extends StatefulWidget {
  final _GenreChip genre;
  final VoidCallback onTap;

  const _GenreTile({required this.genre, required this.onTap});

  @override
  State<_GenreTile> createState() => _GenreTileState();
}

class _GenreTileState extends State<_GenreTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.genre.color.withAlpha(35)
              : widget.genre.color.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.genre.color.withAlpha(_isHovered ? 100 : 45),
            width: _isHovered ? 1.0 : 0.6,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: widget.genre.color.withAlpha(40),
                blurRadius: 16,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.genre.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.genre.icon,
                      color: widget.genre.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.genre.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
