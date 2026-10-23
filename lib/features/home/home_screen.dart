import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sample_data/sample_music_provider.dart';
import '../../services/audio/audio_manager.dart';
import '../../services/auth/auth_service.dart';
import '../../models/song.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../app/router.dart';

/// Home screen — discovery dashboard matching Reference 1.
///
/// Features:
/// - Prominent frosted search field ("Search your vibe")
/// - Category pills ("For you", "Workout", "Feel good", "Energize", "Party", "Relax", "Focus")
/// - Featured glass banner ("Feel the rhythm") with mesh gradient & quick play
/// - Top Artists rounded cards with glow & name label
/// - New Releases & Trending music sections
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> _catalog = [];
  bool _isLoading = true;
  int _selectedChipIndex = 0;

  static const List<String> _chips = [
    'For you',
    'Workout',
    'Feel good',
    'Energize',
    'Party',
    'Relax',
    'Focus',
  ];

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
    final accent = theme.colorScheme.primary;
    final audioManager = context.read<AudioManager>();
    final auth = context.watch<AuthService>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    if (_isLoading) {
      return const Scaffold(
        body: LoadingState(message: 'Loading your music...'),
      );
    }

    final provider = context.read<SampleMusicProvider>();
    final albums = provider.albums;
    final artists = provider.artists;
    final userName = auth.currentUser?.displayName ?? 'Alex';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ─── Top Bar & Search ────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 28 : 16,
                  16,
                  isDesktop ? 28 : 16,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar & Profile Header
                    Row(
                      children: [
                        // Search vibe field
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.search);
                            },
                            child: GlassContainer(
                              height: 46,
                              borderRadius: BorderRadius.circular(24),
                              blur: 16,
                              backgroundColor: Colors.white.withAlpha(14),
                              borderColor: Colors.white.withAlpha(26),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Search your vibe',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withAlpha(140),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Settings icon
                        IconButton(
                          icon: const Icon(Icons.settings_outlined,
                              size: 20, color: Colors.white70),
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRouter.settings);
                          },
                          tooltip: 'Settings',
                        ),
                        // Notification bell
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              size: 20, color: Colors.white70),
                          onPressed: () {},
                          tooltip: 'Notifications',
                        ),
                        // Avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accent.withAlpha(40),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accent.withAlpha(80),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ─── Category Chips ──────────────────────────────
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _chips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedChipIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedChipIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accent
                                    : Colors.white.withAlpha(12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? accent
                                      : Colors.white.withAlpha(22),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _chips[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withAlpha(190),
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Featured Hero Glass Banner ("Feel the rhythm") ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 16,
              ),
              child: _FeaturedHeroBanner(
                catalog: _catalog,
                accent: accent,
                onPlay: () {
                  if (_catalog.isNotEmpty) {
                    audioManager.playQueue(_catalog);
                  }
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ─── Top Artists ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 16,
              ),
              child: Text(
                'Top Artists',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 28 : 16,
                ),
                itemCount: artists.length.clamp(0, 8),
                separatorBuilder: (_, __) => const SizedBox(width: 18),
                itemBuilder: (context, index) {
                  final artistName = artists[index];
                  final artistSongs = provider.songsByArtist(artistName);
                  final photo = artistSongs.isNotEmpty
                      ? artistSongs.first.artworkUrl
                      : '';
                  return _ArtistCard(
                    name: artistName,
                    imageUrl: photo,
                    accent: accent,
                    onTap: () {
                      if (artistSongs.isNotEmpty) {
                        audioManager.playQueue(artistSongs);
                      }
                    },
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ─── New Releases ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 16,
              ),
              child: Row(
                children: [
                  Text(
                    'New Releases',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'See all',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SonoraColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // New Releases List
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28 : 16,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _catalog[index];
                  return SongTile(
                    song: song,
                    isPlaying: audioManager.currentSong?.id == song.id,
                    onTap: () =>
                        audioManager.playQueue(_catalog, startIndex: index),
                  );
                },
                childCount: _catalog.length.clamp(0, 6),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Trending Albums ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 16,
              ),
              child: Text(
                'Trending Albums',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 215,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 28 : 16,
                ),
                itemCount: albums.length.clamp(0, 6),
                separatorBuilder: (_, __) => const SizedBox(width: 14),
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

          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }
}

// ─── Featured Hero Banner ─────────────────────────────────────

class _FeaturedHeroBanner extends StatelessWidget {
  final List<Song> catalog;
  final Color accent;
  final VoidCallback onPlay;

  const _FeaturedHeroBanner({
    required this.catalog,
    required this.accent,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(35),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient digital wave background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF133268),
                      const Color(0xFF0C1B3B),
                      const Color(0xFF090E20),
                    ],
                  ),
                ),
              ),
            ),

            // Radial neon glow
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB).withAlpha(120),
                ),
              ),
            ),

            // Backdrop blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(60),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withAlpha(30),
                    width: 1,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Feel the rhythm',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Discover trending tracks and handpicked favorites made for you.',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha(30),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '${catalog.length} songs | 84 minutes',
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Heart button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(40),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Play button
                      GestureDetector(
                        onTap: onPlay,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withAlpha(80),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Artist Card ──────────────────────────────────────────

class _ArtistCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final Color accent;
  final VoidCallback onTap;

  const _ArtistCard({
    required this.name,
    required this.imageUrl,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withAlpha(25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(90),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _artistPlaceholder(),
                    )
                  else
                    _artistPlaceholder(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _artistPlaceholder() {
    return Container(
      color: const Color(0xFF1E1E26),
      child: const Center(
        child: Icon(Icons.person_rounded, color: Colors.white54, size: 36),
      ),
    );
  }
}
