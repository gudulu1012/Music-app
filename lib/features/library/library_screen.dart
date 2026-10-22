import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sample_data/sample_music_provider.dart';
import '../../data/sample_data/sample_playlists.dart';
import '../../services/audio/audio_manager.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../core/responsive/responsive.dart';
import '../../app/router.dart';

/// Library screen — hub for favorites, playlists, downloads, history.
///
/// Contains clickable tabs: Playlists, Artists, Albums, Songs.
/// Each tab shows the corresponding content from the existing data sources.
class LibraryScreen extends StatefulWidget {
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
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedTab = 0;

  static const List<String> _tabs = ['Playlists', 'Artists', 'Albums', 'Songs'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Text(
                      'Library',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: SonoraColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SonoraColors.surfaceBorder.withAlpha(60),
                          width: 0.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        color: SonoraColors.textSecondary,
                        tooltip: 'Create Playlist',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Tab chips — CLICKABLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        right: index < _tabs.length - 1 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTab = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == index
                              ? accent
                              : SonoraColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedTab == index
                                ? accent
                                : SonoraColors.surfaceBorder.withAlpha(60),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: _selectedTab == index
                                ? Colors.white
                                : SonoraColors.textSecondary,
                            fontSize: 13,
                            fontWeight: _selectedTab == index
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Tab content
          _buildTabContent(context),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return _PlaylistsTab(
          onNavigateToPlaylists: widget.onNavigateToPlaylists,
        );
      case 1:
        return const _ArtistsTab();
      case 2:
        return const _AlbumsTab();
      case 3:
        return const _SongsTab();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// PLAYLISTS TAB
// ═══════════════════════════════════════════════════════════════

class _PlaylistsTab extends StatelessWidget {
  final VoidCallback? onNavigateToPlaylists;

  const _PlaylistsTab({this.onNavigateToPlaylists});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final playlists = SamplePlaylistsProvider.playlists;
    final columns = Responsive.value(context, mobile: 2, tablet: 3, desktop: 4);

    if (playlists.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.queue_music_rounded,
          title: 'No playlists yet',
          subtitle: 'Create a playlist to organize your music',
          action: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Playlist'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final playlist = playlists[index];
            return _GlassPlaylistCard(
              title: playlist.name,
              subtitle: '${playlist.songCount} songs • by Alex',
              imageUrl: playlist.artworkUrl ?? '',
              accent: accent,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushNamed(
                  AppRouter.playlistDetail,
                  arguments: playlist.id,
                );
              },
            );
          },
          childCount: playlists.length,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ARTISTS TAB
// ═══════════════════════════════════════════════════════════════

class _ArtistsTab extends StatelessWidget {
  const _ArtistsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SampleMusicProvider>();
    final artists = provider.artists;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    if (artists.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.person_rounded,
          title: 'No artists found',
          subtitle: 'Start playing music to see artists here',
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final artist = artists[index];
          final songCount = provider.songsByArtist(artist).length;
          return _ArtistTile(
            name: artist,
            songCount: songCount,
            accent: accent,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pushNamed(
                AppRouter.artistDetail,
                arguments: artist,
              );
            },
          );
        },
        childCount: artists.length,
      ),
    );
  }
}

class _ArtistTile extends StatefulWidget {
  final String name;
  final int songCount;
  final Color accent;
  final VoidCallback onTap;

  const _ArtistTile({
    required this.name,
    required this.songCount,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_ArtistTile> createState() => _ArtistTileState();
}

class _ArtistTileState extends State<_ArtistTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _isHovered
              ? SonoraColors.surfaceElevated.withAlpha(80)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: widget.accent.withAlpha(20),
                child: Text(
                  widget.name[0].toUpperCase(),
                  style: TextStyle(
                    color: widget.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.songCount} songs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SonoraColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: SonoraColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ALBUMS TAB
// ═══════════════════════════════════════════════════════════════

class _AlbumsTab extends StatelessWidget {
  const _AlbumsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SampleMusicProvider>();
    final albums = provider.albums;
    final columns = Responsive.value(context, mobile: 2, tablet: 3, desktop: 4);

    if (albums.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.album_rounded,
          title: 'No albums found',
          subtitle: 'Start playing music to see albums here',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final album = albums[index];
            return _AlbumCard(
              name: album.name,
              artist: album.artist,
              imageUrl: album.artworkUrl,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushNamed(
                  AppRouter.albumDetail,
                  arguments: album.name,
                );
              },
            );
          },
          childCount: albums.length,
        ),
      ),
    );
  }
}

class _AlbumCard extends StatefulWidget {
  final String name;
  final String artist;
  final String imageUrl;
  final VoidCallback onTap;

  const _AlbumCard({
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: SonoraColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  SonoraColors.surfaceBorder.withAlpha(_isHovered ? 100 : 40),
              width: 0.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(
                    width: double.infinity,
                    color: SonoraColors.surfaceElevated,
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.album_rounded,
                                  size: 40, color: SonoraColors.textTertiary),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.album_rounded,
                                size: 40, color: SonoraColors.textTertiary),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.artist,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SonoraColors.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SONGS TAB
// ═══════════════════════════════════════════════════════════════

class _SongsTab extends StatelessWidget {
  const _SongsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SampleMusicProvider>();
    final audioManager = context.read<AudioManager>();

    return FutureBuilder(
      future: provider.fetchCatalog(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverFillRemaining(
            child: LoadingState(message: 'Loading songs...'),
          );
        }

        final songs = snapshot.data!;
        if (songs.isEmpty) {
          return const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.music_note_rounded,
              title: 'No songs found',
              subtitle: 'Your music library is empty',
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                index: index + 1,
                isPlaying: audioManager.currentSong?.id == song.id,
                onTap: () => audioManager.playQueue(songs, startIndex: index),
                onMorePressed: () {},
              );
            },
            childCount: songs.length,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASS PLAYLIST CARD (Glassmorphism)
// ═══════════════════════════════════════════════════════════════

class _GlassPlaylistCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color accent;
  final VoidCallback onTap;

  const _GlassPlaylistCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_GlassPlaylistCard> createState() => _GlassPlaylistCardState();
}

class _GlassPlaylistCardState extends State<_GlassPlaylistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: _isHovered
              ? Matrix4.diagonal3Values(1.03, 1.03, 1.0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? widget.accent.withAlpha(60)
                  : Colors.white.withAlpha(15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(_isHovered ? 80 : 40),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
              if (_isHovered)
                BoxShadow(
                  color: widget.accent.withAlpha(20),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: SonoraColors.surfaceCard,
                          child: const Icon(Icons.queue_music_rounded,
                              size: 48, color: SonoraColors.textTertiary),
                        ),
                      )
                    : Container(
                        color: SonoraColors.surfaceCard,
                        child: const Icon(Icons.queue_music_rounded,
                            size: 48, color: SonoraColors.textTertiary),
                      ),
                // Glass overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(20),
                        Colors.black.withAlpha(160),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(180),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Play button
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.7,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(40),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
