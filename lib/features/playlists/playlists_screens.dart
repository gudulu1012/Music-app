import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sample_data/sample_playlists.dart';
import '../../data/sample_data/sample_music_provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../shared/theme/theme_provider.dart';
import '../../app/router.dart';
import '../../models/song.dart';
import '../../models/playlist.dart';

/// Playlists screen with cinematic room background, asymmetric tilted glass cards,
/// and floating controls matching Reference 3.
class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<({String label, IconData icon})> _filters = [
    (label: 'All', icon: Icons.check_circle_rounded),
    (label: 'Mine', icon: Icons.person_rounded),
    (label: 'By Genre', icon: Icons.category_rounded),
    (label: 'Recently Added', icon: Icons.access_time_rounded),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final allPlaylists = SamplePlaylistsProvider.playlists;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    // Filter playlists by search query and category
    final filteredPlaylists = allPlaylists.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(q);
        final matchesDesc = p.description?.toLowerCase().contains(q) ?? false;
        if (!matchesName && !matchesDesc) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0C090A),
      body: Stack(
        children: [
          // ─── Layer 1: Cinematic Room Background ──────────────
          const Positioned.fill(
            child: RepaintBoundary(
              child: CinematicRoomBackground(),
            ),
          ),

          // ─── Layer 2: Main Content Area ──────────────────────
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Top Header + Search & Filter Controls
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
                    child: _buildTopHeader(context, theme, accent, isDesktop),
                  ),
                ),

                // Asymmetric 3D Cards
                if (isDesktop)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 120),
                      child: _buildDesktopAsymmetricLayout(
                        context,
                        filteredPlaylists,
                        accent,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= filteredPlaylists.length) return null;
                          final playlist = filteredPlaylists[index];
                          final rotation = (index % 2 == 0) ? -0.02 : 0.02;
                          return RepaintBoundary(
                            key: ValueKey(playlist.id),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _CinematicPlaylistCard(
                                key: ValueKey('card_${playlist.id}'),
                                playlist: playlist,
                                accent: accent,
                                tiltAngle: rotation,
                                height: 220,
                                onTap: () =>
                                    _openPlaylist(context, playlist.id),
                              ),
                            ),
                          );
                        },
                        childCount: filteredPlaylists.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    ThemeData theme,
    Color accent,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Heading & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Playlists',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your sound. Your space.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(160),
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right: Search Bar & Filters aligned
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Search field
              SizedBox(
                width: 260,
                height: 40,
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(20),
                  blur: 16,
                  backgroundColor: Colors.white.withAlpha(14),
                  borderColor: Colors.white.withAlpha(28),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search playlists...',
                            hintStyle: TextStyle(
                              color: Colors.white.withAlpha(120),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter capsules
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_filters.length, (index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? accent : Colors.black.withAlpha(90),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? accent
                                : Colors.white.withAlpha(25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter.icon,
                              size: 14,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              filter.label,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      );
    }

    // Mobile / Tablet Header
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Playlists',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Your sound. Your space.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withAlpha(160),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        // Search bar
        GlassContainer(
          height: 44,
          borderRadius: BorderRadius.circular(14),
          blur: 16,
          backgroundColor: Colors.white.withAlpha(14),
          borderColor: Colors.white.withAlpha(28),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 20, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search playlists...',
                    hintStyle: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal filter capsules
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? accent : Colors.black.withAlpha(90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? accent : Colors.white.withAlpha(25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.icon,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 5 Asymmetric 3D Tilted Cards layout matching Reference 3 exactly.
  Widget _buildDesktopAsymmetricLayout(
    BuildContext context,
    List<Playlist> playlists,
    Color accent,
  ) {
    // Map playlists by id or fall back by index
    final workout = playlists.firstWhere(
      (p) => p.name.contains('Workout'),
      orElse: () =>
          playlists.isNotEmpty ? playlists[0] : _defaultPlaylist('Workout Mix'),
    );
    final chill = playlists.firstWhere(
      (p) => p.name.contains('Chill'),
      orElse: () =>
          playlists.length > 1 ? playlists[1] : _defaultPlaylist('Chill Vibes'),
    );
    final lateNight = playlists.firstWhere(
      (p) => p.name.contains('Late Night'),
      orElse: () =>
          playlists.length > 2 ? playlists[2] : _defaultPlaylist('Late Night'),
    );
    final indie = playlists.firstWhere(
      (p) => p.name.contains('Indie'),
      orElse: () =>
          playlists.length > 3 ? playlists[3] : _defaultPlaylist('Indie Favs'),
    );
    final mood = playlists.firstWhere(
      (p) => p.name.contains('Mood'),
      orElse: () =>
          playlists.length > 4 ? playlists[4] : _defaultPlaylist('Mood Boost'),
    );

    return Column(
      children: [
        // Top Row: Workout Mix (left tilted), Chill Vibes (featured center), Late Night (right tilted)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Workout Mix — upper-left tilted
            Expanded(
              flex: 10,
              child: _CinematicPlaylistCard(
                playlist: workout,
                accent: accent,
                tiltAngle: -0.04,
                tiltX: 0.02,
                height: 230,
                onTap: () => _openPlaylist(context, workout.id),
              ),
            ),
            const SizedBox(width: 24),

            // 2. Chill Vibes — featured large center card
            Expanded(
              flex: 12,
              child: _CinematicPlaylistCard(
                playlist: chill,
                accent: accent,
                isFeatured: true,
                tiltAngle: 0.01,
                height: 280,
                onTap: () => _openPlaylist(context, chill.id),
              ),
            ),
            const SizedBox(width: 24),

            // 3. Late Night — upper-right tilted
            Expanded(
              flex: 10,
              child: _CinematicPlaylistCard(
                playlist: lateNight,
                accent: accent,
                tiltAngle: 0.05,
                tiltX: -0.02,
                height: 230,
                onTap: () => _openPlaylist(context, lateNight.id),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Bottom Row: Indie Favs (lower-left), Mood Boost (lower-right)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            // 4. Indie Favs — lower-left
            Expanded(
              flex: 8,
              child: _CinematicPlaylistCard(
                playlist: indie,
                accent: accent,
                tiltAngle: -0.03,
                height: 220,
                onTap: () => _openPlaylist(context, indie.id),
              ),
            ),
            const SizedBox(width: 32),

            // 5. Mood Boost — lower-right
            Expanded(
              flex: 8,
              child: _CinematicPlaylistCard(
                playlist: mood,
                accent: accent,
                tiltAngle: 0.04,
                height: 220,
                onTap: () => _openPlaylist(context, mood.id),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ],
    );
  }

  Playlist _defaultPlaylist(String name) {
    return Playlist(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      description: 'Curated sound space',
      ownerId: 'alex',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      songIds: const [],
      isPublic: true,
    );
  }

  void _openPlaylist(BuildContext context, String playlistId) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      AppRouter.playlistDetail,
      arguments: playlistId,
    );
  }
}

/// Playlist detail screen — shows songs in a specific playlist.
class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final playlist = SamplePlaylistsProvider.getById(playlistId);
    final provider = context.read<SampleMusicProvider>();
    final audioManager = context.read<AudioManager>();

    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: SonoraColors.background,
        ),
        body: const EmptyState(
          icon: Icons.queue_music_rounded,
          title: 'Playlist not found',
          subtitle: 'This playlist may have been deleted',
        ),
      );
    }

    return FutureBuilder<List<Song>>(
      future: provider.fetchSongsByIds(playlist.songIds),
      builder: (context, snapshot) {
        final songs = snapshot.data ?? [];

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero section with cinematic gradient
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withAlpha(50),
                        SonoraColors.background,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        children: [
                          // Nav bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert,
                                    color: SonoraColors.textSecondary),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Artwork with glass effect
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withAlpha(30),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: playlist.artworkUrl != null &&
                                      playlist.artworkUrl!.isNotEmpty
                                  ? Image.network(
                                      playlist.artworkUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _artworkPlaceholder(),
                                    )
                                  : _artworkPlaceholder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Playlist info
                          Text(
                            playlist.name,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${playlist.songCount} songs • by Alex',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: SonoraColors.textSecondary,
                            ),
                          ),
                          if (playlist.description != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              playlist.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: SonoraColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play button
                      GestureDetector(
                        onTap: () {
                          if (songs.isNotEmpty) {
                            audioManager.playQueue(songs);
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withAlpha(60),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _ActionCircle(
                        icon: Icons.shuffle_rounded,
                        onTap: () {
                          if (songs.isNotEmpty) {
                            final shuffled = List<Song>.from(songs)..shuffle();
                            audioManager.playQueue(shuffled);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _ActionCircle(
                        icon: Icons.download_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _ActionCircle(
                        icon: Icons.more_horiz_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),

              // Song list header
              if (songs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 28),
                        const SizedBox(width: 12),
                        const SizedBox(width: 46 + 12),
                        Expanded(
                          child: Text(
                            'Title',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SonoraColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            'Artist',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SonoraColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 14, color: SonoraColors.textTertiary),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

              // Song list
              if (songs.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.music_note_rounded,
                    title: 'This playlist is empty',
                    subtitle: 'Add songs from the search or home screen',
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      final isCurrent = audioManager.currentSong?.id == song.id;
                      return _PlaylistSongTile(
                        song: song,
                        index: index + 1,
                        isCurrent: isCurrent,
                        accent: accent,
                        onTap: () =>
                            audioManager.playQueue(songs, startIndex: index),
                      );
                    },
                    childCount: songs.length,
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      color: SonoraColors.surfaceElevated,
      child: const Icon(
        Icons.queue_music_rounded,
        size: 64,
        color: SonoraColors.textTertiary,
      ),
    );
  }
}

// ─── Playlist Song Tile (with duration and favorite) ──────────

class _PlaylistSongTile extends StatefulWidget {
  final Song song;
  final int index;
  final bool isCurrent;
  final Color accent;
  final VoidCallback onTap;

  const _PlaylistSongTile({
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_PlaylistSongTile> createState() => _PlaylistSongTileState();
}

class _PlaylistSongTileState extends State<_PlaylistSongTile> {
  bool _isHovered = false;
  bool _isFavorited = false;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isCurrent
                ? widget.accent.withAlpha(10)
                : _isHovered
                    ? SonoraColors.surfaceElevated.withAlpha(60)
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: SonoraColors.surfaceBorder.withAlpha(20),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Index
              SizedBox(
                width: 28,
                child: Text(
                  '${widget.index}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.isCurrent
                        ? widget.accent
                        : SonoraColors.textTertiary,
                    fontWeight:
                        widget.isCurrent ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              // Artwork
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  color: SonoraColors.surfaceElevated,
                  child: widget.song.artworkUrl.isNotEmpty
                      ? Image.network(
                          widget.song.artworkUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.music_note_rounded,
                            size: 18,
                            color: SonoraColors.textTertiary,
                          ),
                        )
                      : const Icon(
                          Icons.music_note_rounded,
                          size: 18,
                          color: SonoraColors.textTertiary,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Text(
                  widget.song.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: widget.isCurrent ? widget.accent : null,
                    fontWeight:
                        widget.isCurrent ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Artist
              SizedBox(
                width: 120,
                child: Text(
                  widget.song.artist,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SonoraColors.textTertiary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Duration
              SizedBox(
                width: 44,
                child: Text(
                  widget.song.formattedDuration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SonoraColors.textTertiary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              // Favorite
              IconButton(
                icon: Icon(
                  _isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 16,
                  color:
                      _isFavorited ? widget.accent : SonoraColors.textTertiary,
                ),
                onPressed: () {
                  setState(() => _isFavorited = !_isFavorited);
                },
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              // More
              IconButton(
                icon: const Icon(Icons.more_vert, size: 16),
                onPressed: () {},
                color: SonoraColors.textTertiary,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cinematic Playlist Card (3D Tilt & Glassmorphism) ────────

class _CinematicPlaylistCard extends StatefulWidget {
  final Playlist playlist;
  final Color accent;
  final double tiltAngle;
  final double tiltX;
  final double height;
  final bool isFeatured;
  final VoidCallback onTap;

  const _CinematicPlaylistCard({
    super.key,
    required this.playlist,
    required this.accent,
    this.tiltAngle = 0.0,
    this.tiltX = 0.0,
    this.height = 230,
    this.isFeatured = false,
    required this.onTap,
  });

  @override
  State<_CinematicPlaylistCard> createState() => _CinematicPlaylistCardState();
}

class _CinematicPlaylistCardState extends State<_CinematicPlaylistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioManager = context.read<AudioManager>();
    final musicProvider = context.read<SampleMusicProvider>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateZ(_isHovered ? 0.0 : widget.tiltAngle)
      ..rotateX(_isHovered ? 0.0 : widget.tiltX);

    if (_isHovered) {
      matrix.multiply(Matrix4.diagonal3Values(1.035, 1.035, 1.0));
    }

    // Adapt blur & shadow radii for mobile to ensure fluid 60fps scrolling
    final blurSigma = isDesktop ? 16.0 : 8.0;
    final shadowBlur1 = isDesktop ? (_isHovered ? 36.0 : 24.0) : 14.0;
    final shadowBlur2 = isDesktop
        ? (widget.isFeatured ? 42.0 : 32.0)
        : (widget.isFeatured ? 18.0 : 12.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          transform: matrix,
          transformAlignment: Alignment.center,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              // 1. Deep occlusion shadow
              BoxShadow(
                color: Colors.black.withAlpha(_isHovered ? 180 : 130),
                blurRadius: shadowBlur1,
                offset: const Offset(0, 16),
              ),
              // 2. Ambient theme-tinted glow
              BoxShadow(
                color: widget.accent.withAlpha(_isHovered ? 45 : 20),
                blurRadius: shadowBlur2,
                spreadRadius: widget.isFeatured ? 2 : 0,
              ),
              // 3. Contact shadow
              BoxShadow(
                color: Colors.black.withAlpha(90),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ─── Layer 1: True Backdrop Filter (Frosted Glass Core) ──
                BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(
                    color:
                        const Color(0x2E14121A), // Translucent smoke glass tint
                  ),
                ),

                // ─── Layer 2: Inset Artwork Surface ──────────────────────
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  height: widget.height * 0.60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.playlist.artworkUrl != null &&
                                widget.playlist.artworkUrl!.isNotEmpty
                            ? Image.network(
                                widget.playlist.artworkUrl!,
                                fit: BoxFit.cover,
                                cacheWidth: isDesktop ? 600 : 400,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackArt(),
                              )
                            : _buildFallbackArt(),

                        // Soft ambient gradient over artwork for contrast & glass depth
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withAlpha(25),
                                Colors.transparent,
                                Colors.black.withAlpha(120),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),

                        // Fine inner border around inset artwork
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withAlpha(35),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Layer 3: Lower Glass Shelf & Content ────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: widget.height * 0.42,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x3018151E),
                          Color(0xD00E0C12),
                          Color(0xF209070C),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title + Count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.playlist.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: widget.isFeatured ? 19 : 16,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${widget.playlist.songCount} songs • by Alex',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withAlpha(175),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Circular Frosted Glass Play Control
                        GestureDetector(
                          onTap: () async {
                            final songs = await musicProvider
                                .fetchSongsByIds(widget.playlist.songIds);
                            if (songs.isNotEmpty) {
                              audioManager.playQueue(songs);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withAlpha(_isHovered ? 255 : 220),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(110),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.black87,
                                size: 23,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Layer 4: Diagonal Glass Reflection Gleam ────────────
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: const Alignment(-1.0, -1.2),
                        end: const Alignment(1.0, 1.2),
                        colors: [
                          Colors.white.withAlpha(_isHovered ? 45 : 28),
                          Colors.white.withAlpha(10),
                          Colors.transparent,
                          Colors.white.withAlpha(_isHovered ? 15 : 8),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.22, 0.42, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),

                // ─── Layer 5: Refractive Glass Edge Highlights ───────────
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withAlpha(_isHovered ? 75 : 45),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),

                // Bright top-left specular highlight edge
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withAlpha(_isHovered ? 160 : 110),
                          width: 1.4,
                        ),
                        left: BorderSide(
                          color: Colors.white.withAlpha(_isHovered ? 110 : 75),
                          width: 1.2,
                        ),
                        bottom: BorderSide(
                          color: Colors.white.withAlpha(15),
                          width: 0.8,
                        ),
                        right: BorderSide(
                          color: Colors.white.withAlpha(20),
                          width: 0.8,
                        ),
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

  Widget _buildFallbackArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accent.withAlpha(80),
            const Color(0xFF1F1018),
            const Color(0xFF0F080C),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 48,
          color: Colors.white.withAlpha(60),
        ),
      ),
    );
  }
}

// ─── Cinematic Room Background ────────────────────────────────

/// Renders the warm, ambient sunset living room interior specified in Reference 3.
/// Self-contained, beautiful, responsive, and works offline.
class CinematicRoomBackground extends StatelessWidget {
  const CinematicRoomBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final themeType = context.watch<ThemeProvider>().currentTheme;

    return CustomPaint(
      painter: _CinematicRoomPainter(themeType: themeType),
      size: Size.infinite,
    );
  }
}

class _CinematicRoomPainter extends CustomPainter {
  final SonoraThemeType themeType;

  const _CinematicRoomPainter({required this.themeType});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ─── Specialization: Pink Glass Luxury Glassmorphism ──────
    // Matches the Dribbble reference: deep burgundy/black cherry base, saturated
    // crimson/ruby red glow pools, soft blush-white diffused blooms, and dark wine vignette.
    if (themeType == SonoraThemeType.pinkGlass) {
      _paintPinkGlassBackground(canvas, size, rect);
      return;
    }

    // ─── 1. Theme-Harmonized Color Schemes ────────────────────
    final Color baseDark;
    final Color baseMid;
    final Color baseDeep;
    final Color bloomPrimary;
    final Color bloomSecondary;
    final Color floorSpill;
    final Color atmosphericLight;

    switch (themeType) {
      case SonoraThemeType.crimsonMinimal:
        baseDark = const Color(0xFF0F0407);
        baseMid = const Color(0xFF18060B);
        baseDeep = const Color(0xFF070204);
        bloomPrimary = const Color(0xFFDC2626);
        bloomSecondary = const Color(0xFF991B1B);
        floorSpill = const Color(0xFF7F1D1D);
        atmosphericLight = const Color(0xFFF87171);
        break;
      case SonoraThemeType.emeraldDark:
        baseDark = const Color(0xFF020E07);
        baseMid = const Color(0xFF04190E);
        baseDeep = const Color(0xFF010704);
        bloomPrimary = const Color(0xFF10B981);
        bloomSecondary = const Color(0xFF047857);
        floorSpill = const Color(0xFF065F46);
        atmosphericLight = const Color(0xFF6EE7B7);
        break;
      case SonoraThemeType.amberWarm:
        baseDark = const Color(0xFF0E0905);
        baseMid = const Color(0xFF1B1007);
        baseDeep = const Color(0xFF070402);
        bloomPrimary = const Color(0xFFF59E0B);
        bloomSecondary = const Color(0xFFD97706);
        floorSpill = const Color(0xFFB45309);
        atmosphericLight = const Color(0xFFFDE68A);
        break;
      case SonoraThemeType.slateBlue:
        baseDark = const Color(0xFF040A14);
        baseMid = const Color(0xFF071424);
        baseDeep = const Color(0xFF02050A);
        bloomPrimary = const Color(0xFF38BDF8);
        bloomSecondary = const Color(0xFF0284C7);
        floorSpill = const Color(0xFF0369A1);
        atmosphericLight = const Color(0xFFBAE6FD);
        break;
      case SonoraThemeType.pinkGlass:
        baseDark = const Color(0xFF1E0308);
        baseMid = const Color(0xFF2E040D);
        baseDeep = const Color(0xFF140205);
        bloomPrimary = const Color(0xFFD20D3A);
        bloomSecondary = const Color(0xFFA50828);
        floorSpill = const Color(0xFF6B0518);
        atmosphericLight = const Color(0xFFFFE2EB);
        break;
    }

    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseDark, baseMid, baseDeep],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // ─── 3. Primary Ambient Window Bloom (Top-Right) ──────────
    final windowBloomPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.72, -0.32),
        radius: 1.15,
        colors: [
          atmosphericLight.withAlpha(125),
          bloomPrimary.withAlpha(80),
          bloomSecondary.withAlpha(35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.32, 0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, windowBloomPaint);

    // ─── 4. Architectural Light Shaft (Soft Angled Beam) ──────
    final lightShaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          bloomPrimary.withAlpha(45),
          bloomSecondary.withAlpha(18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.85],
      ).createShader(rect);

    final shaftPath = Path()
      ..moveTo(size.width * 0.52, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width * 0.35, size.height)
      ..lineTo(size.width * 0.18, size.height)
      ..close();
    canvas.drawPath(shaftPath, lightShaftPaint);

    // ─── 5. Floor Light Spill & Warm Reflection ───────────────
    final floorSpillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.35, 0.78),
        radius: 0.9,
        colors: [
          floorSpill.withAlpha(35),
          bloomSecondary.withAlpha(15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, floorSpillPaint);

    // ─── 6. Restrained Architectural Silhouette (Deep Shadows) ─
    final silhouettePaint = Paint()..color = baseDeep.withAlpha(170);
    final roomDetailPath = Path();
    final pX = size.width * 0.92;
    final pY = size.height * 0.46;
    // Organic interior shadow curve
    roomDetailPath.moveTo(pX, pY);
    roomDetailPath.quadraticBezierTo(pX - 50, pY - 70, pX - 90, pY - 150);
    roomDetailPath.quadraticBezierTo(pX - 40, pY - 80, pX, pY);
    roomDetailPath.quadraticBezierTo(pX - 90, pY - 20, pX - 140, pY - 40);
    roomDetailPath.quadraticBezierTo(pX - 60, pY - 5, pX, pY);
    canvas.drawPath(roomDetailPath, silhouettePaint);

    // ─── 7. Cinematic Radial Vignette ─────────────────────────
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.05),
        radius: 1.15,
        colors: [
          Colors.transparent,
          Colors.black.withAlpha(90),
          Colors.black.withAlpha(195),
        ],
        stops: const [0.35, 0.75, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  /// Renders the luxury cinematic Pink Glass theme background matching the
  /// reference design: deep burgundy/black cherry base with saturated ruby
  /// and crimson glow pools, diffused soft blush highlights, and a dark wine vignette.
  void _paintPinkGlassBackground(Canvas canvas, Size size, Rect rect) {
    // 1. Base Gradient: Very deep burgundy to black cherry diagonal wash
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.85, -1.0),
        end: const Alignment(0.85, 1.0),
        colors: const [
          Color(0xFF1E0308), // Corner deep wine
          Color(0xFF28040C), // Burgundy
          Color(0xFF380510), // Rich black cherry core
          Color(0xFF24030A), // Deep burgundy
          Color(0xFF140205), // Corner dark wine
        ],
        stops: const [0.0, 0.28, 0.52, 0.78, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // 2. Primary Saturated Crimson & Ruby Red Glow (Upper-Left Region)
    // Saturated ruby illumination radiating behind the top-left cards & header
    final rubyGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.42, -0.36),
        radius: 1.15,
        colors: [
          const Color(0xFFD20D3A).withAlpha(175), // Saturated ruby crimson
          const Color(0xFFBA0A30).withAlpha(135),
          const Color(0xFFA50828).withAlpha(85), // Deep crimson
          const Color(0xFF5A0415).withAlpha(30), // Deep wine falloff
          Colors.transparent,
        ],
        stops: const [0.0, 0.26, 0.52, 0.78, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, rubyGlowPaint);

    // 3. Diffused Pink-White Light Bloom (Upper-Left Core)
    // Broad, soft, diffused blush highlight that feathers naturally into the red glow
    final pinkBloomPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.32, -0.42),
        radius: 0.75,
        colors: [
          const Color(0xFFFFE2EB).withAlpha(85), // Soft diffused pink-white
          const Color(0xFFF29AB5).withAlpha(50), // Soft rose & blush pink
          const Color(0xFFDC2858)
              .withAlpha(20), // Feathering crimson transition
          Colors.transparent,
        ],
        stops: const [0.0, 0.28, 0.60, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, pinkBloomPaint);

    // 4. Secondary Crimson & Ruby Red Glow (Center-Right / Lower-Right Region)
    final secondaryRubyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.62, 0.30),
        radius: 1.05,
        colors: [
          const Color(0xFFC40C33).withAlpha(140),
          const Color(0xFFA50828).withAlpha(95),
          const Color(0xFF6B0518).withAlpha(40),
          Colors.transparent,
        ],
        stops: const [0.0, 0.30, 0.62, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, secondaryRubyPaint);

    // 5. Diffused Rose Accent Glow (Center-Right Core)
    final roseAccentPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.52, 0.22),
        radius: 0.60,
        colors: [
          const Color(0xFFF8B8CC).withAlpha(55),
          const Color(0xFFE24C74).withAlpha(25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, roseAccentPaint);

    // 6. Subtle Atmospheric Directional Drift (Smoothing Pass)
    // Seamlessly connects the glow regions without harsh edges or banding
    final driftPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.6, -0.7),
        end: const Alignment(0.6, 0.7),
        colors: [
          const Color(0xFFD20D3A).withAlpha(30),
          const Color(0xFFF29AB5).withAlpha(15),
          const Color(0xFFA50828).withAlpha(25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, driftPaint);

    // 7. Cinematic Dark Wine-Red Vignette
    // Keeps edges & corners deep wine/black cherry for depth and high contrast text legibility
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.05),
        radius: 1.25,
        colors: [
          Colors.transparent,
          Colors.transparent,
          const Color(0xFF140205).withAlpha(80),
          const Color(0xFF0F0104).withAlpha(170),
          const Color(0xFF0A0103).withAlpha(225),
        ],
        stops: const [0.0, 0.40, 0.72, 0.90, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _CinematicRoomPainter oldDelegate) =>
      oldDelegate.themeType != themeType;
}

// ─── Action Circle ────────────────────────────────────────────

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCircle({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SonoraColors.surfaceElevated,
          border: Border.all(
            color: SonoraColors.surfaceBorder.withAlpha(60),
            width: 0.5,
          ),
        ),
        child: Icon(icon, color: SonoraColors.textSecondary, size: 20),
      ),
    );
  }
}

/// Album detail screen — shows tracks in an album.
class AlbumDetailScreen extends StatelessWidget {
  final String albumName;

  const AlbumDetailScreen({super.key, required this.albumName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final provider = context.read<SampleMusicProvider>();
    final audioManager = context.read<AudioManager>();
    final songs = provider.songsByAlbum(albumName);
    final album = provider.albums.where((a) => a.name == albumName).firstOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withAlpha(50),
                    SonoraColors.background,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          Text(albumName, style: theme.textTheme.titleLarge),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha(15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(30),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: album != null && album.artworkUrl.isNotEmpty
                              ? Image.network(
                                  album.artworkUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: SonoraColors.surfaceCard,
                                    child: const Icon(Icons.album_rounded,
                                        size: 64,
                                        color: SonoraColors.textTertiary),
                                  ),
                                )
                              : Container(
                                  color: SonoraColors.surfaceCard,
                                  child: const Icon(Icons.album_rounded,
                                      size: 64,
                                      color: SonoraColors.textTertiary),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (album != null)
                        Text(
                          album.artist,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: SonoraColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: songs.isNotEmpty
                          ? () => audioManager.playQueue(songs)
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: songs.isNotEmpty
                          ? () {
                              final shuffled = List<Song>.from(songs)
                                ..shuffle();
                              audioManager.playQueue(shuffled);
                            }
                          : null,
                      icon: const Icon(Icons.shuffle_rounded),
                      label: const Text('Shuffle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (songs.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.album_rounded,
                title: 'No tracks found',
                subtitle: 'This album has no tracks',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  return SongTile(
                    song: song,
                    index: index + 1,
                    isPlaying: audioManager.currentSong?.id == song.id,
                    onTap: () =>
                        audioManager.playQueue(songs, startIndex: index),
                    onMorePressed: () {},
                  );
                },
                childCount: songs.length,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

/// Artist detail screen.
class ArtistDetailScreen extends StatelessWidget {
  final String artistName;

  const ArtistDetailScreen({super.key, required this.artistName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final provider = context.read<SampleMusicProvider>();
    final audioManager = context.read<AudioManager>();
    final songs = provider.songsByArtist(artistName);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withAlpha(50),
                    SonoraColors.background,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: accent.withAlpha(20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withAlpha(40),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(30),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            artistName[0].toUpperCase(),
                            style: TextStyle(
                              color: accent,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(artistName, style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${songs.length} songs',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: SonoraColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: songs.isNotEmpty
                          ? () => audioManager.playQueue(songs)
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: songs.isNotEmpty
                          ? () {
                              final shuffled = List<Song>.from(songs)
                                ..shuffle();
                              audioManager.playQueue(shuffled);
                            }
                          : null,
                      icon: const Icon(Icons.shuffle_rounded),
                      label: const Text('Shuffle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (songs.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.person_rounded,
                title: 'No songs found',
                subtitle: 'No songs by this artist',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  return SongTile(
                    song: song,
                    index: index + 1,
                    isPlaying: audioManager.currentSong?.id == song.id,
                    onTap: () =>
                        audioManager.playQueue(songs, startIndex: index),
                    onMorePressed: () {},
                  );
                },
                childCount: songs.length,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
