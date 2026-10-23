import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../services/audio/audio_manager.dart';
import '../../services/auth/auth_service.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../shared/theme/theme_provider.dart';
import '../../core/utils/format_utils.dart';

/// Now Playing — immersive player inspired by Reference 2.
///
/// Features:
/// - Concentric vinyl record disc presentation with center album art
/// - Audio waveform visualizer responsive to playback state
/// - Frosted glass controls panel with genuine BackdropFilter
/// - Accurate seek bar, timestamps, and full playback controls
/// - Pop-out volume slider, animated heart favorites, resizable queue, and lyrics sheet
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _showDesktopQueue = false;
  double _desktopQueueWidth = 360.0;
  bool _showVolumePopout = false;
  final FocusNode _keyboardFocusNode = FocusNode();
  final Set<String> _localFavorites = {};

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  void _loadFavorites() {
    try {
      final auth = context.read<AuthService>();
      final userId = auth.currentUser?.uid;
      if (userId != null) {
        final favRepo = context.read<FavoritesRepository>();
        favRepo.getFavoriteIds(userId).then((ids) {
          if (mounted && ids.isNotEmpty) {
            setState(() {
              _localFavorites.addAll(ids);
            });
          }
        });
      }
    } catch (_) {}
  }

  bool _isCurrentSongFavorite(String songId) {
    return _localFavorites.contains(songId);
  }

  void _toggleSongFavorite(String songId) async {
    final willBeFav = !_localFavorites.contains(songId);
    setState(() {
      if (willBeFav) {
        _localFavorites.add(songId);
      } else {
        _localFavorites.remove(songId);
      }
    });

    try {
      final auth = context.read<AuthService>();
      final userId = auth.currentUser?.uid;
      if (userId != null) {
        final favRepo = context.read<FavoritesRepository>();
        await favRepo.toggleFavorite(userId, songId);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final song = audioManager.currentSong;

    if (audioManager.isPlaying) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      if (_rotationController.isAnimating) {
        _rotationController.stop();
      }
    }

    if (song == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const EmptyState(
          icon: Icons.music_off_rounded,
          title: 'Nothing playing',
          subtitle: 'Play a song to see it here',
        ),
      );
    }

    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final themeProvider = context.watch<ThemeProvider>();
    final isPinkGlass = themeProvider.currentTheme == SonoraThemeType.pinkGlass;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape &&
              _showVolumePopout) {
            setState(() => _showVolumePopout = false);
          }
        },
        child: Stack(
          children: [
            // ─── Ambient Glow Bloom ─────────────────────────────
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPinkGlass
                      ? const Color(0xFFD20D3A).withAlpha(65)
                      : accent.withAlpha(45),
                ),
              ),
            ),
            if (isPinkGlass)
              Positioned(
                top: 40,
                right: 30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF29AB5).withAlpha(40),
                  ),
                ),
              ),
            Positioned(
              bottom: 120,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPinkGlass
                      ? const Color(0xFFA50828).withAlpha(50)
                      : accent.withAlpha(30),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),

            // ─── Main Content ──────────────────────────────────
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;
                  final discSize = isDesktop ? 250.0 : 210.0;

                  final playerCore = Column(
                    children: [
                      // ─── Top Bar ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 30,
                                  color: Colors.white70),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              'Music play',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            _AnimatedHeartButton(
                              isFavorite: _isCurrentSongFavorite(song.id),
                              onToggle: () => _toggleSongFavorite(song.id),
                              accent: accent,
                              size: 22,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ─── Song Title & Artist ─────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              song.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 23,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withAlpha(170),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ─── Center: Stylized Vinyl Record ───────────
                      Center(
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationController.value * 2 * math.pi,
                              child: child,
                            );
                          },
                          child: _VinylRecordArtwork(
                            artworkUrl: song.artworkUrl,
                            accent: accent,
                            size: discSize,
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ─── Waveform Visualizer ─────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: _WaveformVisualizer(
                          isPlaying: audioManager.isPlaying,
                          accent: accent,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ─── Frosted Glass Player Controls Card ──────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(24),
                          blur: 24,
                          backgroundColor: Colors.white.withAlpha(12),
                          borderColor: Colors.white.withAlpha(25),
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Scrub Slider
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3.5,
                                  activeTrackColor: accent,
                                  inactiveTrackColor:
                                      Colors.white.withAlpha(20),
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 5.5,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 11,
                                  ),
                                ),
                                child: Slider(
                                  value: audioManager.progress.clamp(0.0, 1.0),
                                  onChanged: (value) {
                                    final newPos = Duration(
                                      milliseconds: (value *
                                              audioManager
                                                  .duration.inMilliseconds)
                                          .round(),
                                    );
                                    audioManager.seek(newPos);
                                  },
                                ),
                              ),

                              // Time Labels
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      FormatUtils.duration(
                                          audioManager.position),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(160),
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      FormatUtils.duration(
                                          audioManager.duration),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(160),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Primary Playback Controls
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Shuffle
                                  IconButton(
                                    icon: Icon(
                                      Icons.shuffle_rounded,
                                      color: audioManager.shuffleEnabled
                                          ? accent
                                          : Colors.white60,
                                      size: 20,
                                    ),
                                    onPressed: audioManager.toggleShuffle,
                                    tooltip: 'Shuffle',
                                  ),
                                  // Previous
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_previous_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: audioManager.previous,
                                    tooltip: 'Previous',
                                  ),
                                  // Play / Pause prominent button
                                  GestureDetector(
                                    onTap: audioManager.togglePlayPause,
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withAlpha(90),
                                            blurRadius: 18,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        audioManager.isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  // Next
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_next_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: audioManager.next,
                                    tooltip: 'Next',
                                  ),
                                  // Repeat
                                  IconButton(
                                    icon: Icon(
                                      audioManager.repeatMode == RepeatMode.one
                                          ? Icons.repeat_one_rounded
                                          : Icons.repeat_rounded,
                                      color: audioManager.repeatMode !=
                                              RepeatMode.off
                                          ? accent
                                          : Colors.white60,
                                      size: 20,
                                    ),
                                    onPressed: audioManager.cycleRepeatMode,
                                    tooltip: 'Repeat',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ─── Bottom Actions (Favorite, Lyrics, Volume, Queue, Share) ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _AnimatedHeartButton(
                              isFavorite: _isCurrentSongFavorite(song.id),
                              onToggle: () => _toggleSongFavorite(song.id),
                              accent: accent,
                              size: 22,
                            ),
                            IconButton(
                              icon: const Icon(Icons.lyrics_outlined,
                                  size: 22, color: Colors.white70),
                              onPressed: () => _showLyricsSheet(context, song),
                              tooltip: 'Lyrics',
                            ),
                            IconButton(
                              icon: Icon(
                                audioManager.volume == 0
                                    ? Icons.volume_off_rounded
                                    : (audioManager.volume > 0.5
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_down_rounded),
                                size: 22,
                                color:
                                    _showVolumePopout ? accent : Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showVolumePopout = !_showVolumePopout;
                                });
                              },
                              tooltip: 'Volume',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.queue_music_rounded,
                                size: 24,
                                color: (_showDesktopQueue && isDesktop)
                                    ? accent
                                    : Colors.white70,
                              ),
                              onPressed: () {
                                if (isDesktop) {
                                  setState(() {
                                    _showDesktopQueue = !_showDesktopQueue;
                                  });
                                } else {
                                  _showMobileQueueSheet(
                                      context, audioManager, accent);
                                }
                              },
                              tooltip: 'Queue',
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_rounded,
                                  size: 20, color: Colors.white70),
                              onPressed: () {},
                              tooltip: 'Share',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  );

                  final minQueueWidth = 280.0;
                  final maxQueueWidth =
                      (constraints.maxWidth - 440.0).clamp(320.0, 620.0);
                  final effectiveQueueWidth =
                      _desktopQueueWidth.clamp(minQueueWidth, maxQueueWidth);

                  // Calculate horizontal placement for vertically-centered volume capsule:
                  // 1. Desktop without queue: rightmost edge of main player area (24px margin)
                  // 2. Desktop with queue: immediately to the left of the queue panel (14px gap)
                  // 3. Mobile: rightmost side of phone's player area (16px margin)
                  final double volumeCapsuleRight;
                  if (isDesktop) {
                    if (_showDesktopQueue) {
                      volumeCapsuleRight = (effectiveQueueWidth + 14.0) + 14.0;
                    } else {
                      volumeCapsuleRight = 24.0;
                    }
                  } else {
                    volumeCapsuleRight = 16.0;
                  }

                  final double capsuleHeight =
                      (constraints.maxHeight * 0.35).clamp(125.0, 185.0);

                  final mainContent = isDesktop
                      ? Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 600),
                                  child: playerCore,
                                ),
                              ),
                            ),
                            if (_showDesktopQueue)
                              _DesktopNowPlayingQueue(
                                audioManager: audioManager,
                                accent: accent,
                                width: effectiveQueueWidth,
                                onResizeDelta: (delta) {
                                  setState(() {
                                    _desktopQueueWidth = (_desktopQueueWidth -
                                            delta)
                                        .clamp(minQueueWidth, maxQueueWidth);
                                  });
                                },
                                onClose: () =>
                                    setState(() => _showDesktopQueue = false),
                              ),
                          ],
                        )
                      : playerCore;

                  return Stack(
                    children: [
                      mainContent,

                      // ─── Floating Volume Pop-out Panel ─────────────────
                      if (_showVolumePopout) ...[
                        // Full-screen backdrop barrier to dismiss on click outside
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                setState(() => _showVolumePopout = false),
                            child: const ColoredBox(color: Colors.transparent),
                          ),
                        ),

                        // Vertically centered volume capsule positioned responsively
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: volumeCapsuleRight,
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, val, child) {
                                return Transform.scale(
                                  scale: 0.88 + (val * 0.12),
                                  alignment: Alignment.centerRight,
                                  child: Opacity(
                                    opacity: val.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: _VerticalVolumeCapsule(
                                audioManager: audioManager,
                                accent: accent,
                                height: capsuleHeight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileQueueSheet(
      BuildContext context, AudioManager audioManager, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF160912),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Playback Queue',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withAlpha(35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${audioManager.queue.length}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (audioManager.queue.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            audioManager.clearQueue();
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                Expanded(
                  child: _NowPlayingQueueContent(
                    audioManager: audioManager,
                    accent: accent,
                    scrollController: scrollController,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLyricsSheet(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF160912),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Lyrics',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.title} • ${song.artist}',
                    style: TextStyle(color: Colors.white.withAlpha(160)),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: const [
                        Text(
                          "[Verse 1]\nLost in the midnight neon glow\nEvery beat takes me where to go\nShadows dancing on the city street\nSynchronized to this electric beat\n\n[Chorus]\nFeel the rhythm through the night\nEverything is glowing bright\nIn this space of sound and light\nWe are alive, we are alight\n\n[Verse 2]\nMelodies carry us away\nUntil the breaking of the day\nGlass and silver, echo and chord\nNothing here can be ignored\n\n[Outro]\nYour sound, your space\nForever in this place...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Vertical Volume Capsule ──────────────────────────────────

class _VerticalVolumeCapsule extends StatelessWidget {
  final AudioManager audioManager;
  final Color accent;
  final double height;

  const _VerticalVolumeCapsule({
    required this.audioManager,
    required this.accent,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final vol = audioManager.volume.clamp(0.0, 1.0);
    final isMuted = vol == 0.0;

    return Material(
      color: Colors.transparent,
      child: GlassContainer(
        width: 42,
        height: height,
        borderRadius: BorderRadius.circular(21),
        blur: 24,
        backgroundColor: const Color(0xFF140812).withAlpha(245),
        borderColor: Colors.white.withAlpha(35),
        padding: const EdgeInsets.symmetric(vertical: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(160),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: accent.withAlpha(35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Mute / Unmute Button
            GestureDetector(
              onTap: () {
                if (isMuted) {
                  audioManager.setVolume(0.7);
                } else {
                  audioManager.setVolume(0.0);
                }
              },
              child: Icon(
                isMuted
                    ? Icons.volume_off_rounded
                    : (vol > 0.5
                        ? Icons.volume_up_rounded
                        : Icons.volume_down_rounded),
                size: 17,
                color: isMuted ? Colors.white38 : Colors.white,
              ),
            ),
            // Vertical Slider
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: RotatedBox(
                  quarterTurns: 3, // 270 degrees: bottom is 0.0, top is 1.0
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.5,
                      activeTrackColor: accent,
                      inactiveTrackColor: Colors.white.withAlpha(24),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5.5,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                    ),
                    child: Slider(
                      value: vol,
                      onChanged: (val) => audioManager.setVolume(val),
                    ),
                  ),
                ),
              ),
            ),
            // Percentage indicator
            Text(
              '${(vol * 100).round()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Desktop Now Playing Queue Panel ──────────────────────────

class _DesktopNowPlayingQueue extends StatefulWidget {
  final AudioManager audioManager;
  final Color accent;
  final VoidCallback onClose;
  final double width;
  final ValueChanged<double>? onResizeDelta;

  const _DesktopNowPlayingQueue({
    required this.audioManager,
    required this.accent,
    required this.onClose,
    this.width = 360,
    this.onResizeDelta,
  });

  @override
  State<_DesktopNowPlayingQueue> createState() =>
      _DesktopNowPlayingQueueState();
}

class _DesktopNowPlayingQueueState extends State<_DesktopNowPlayingQueue> {
  bool _isDragging = false;
  bool _isHoveringHandle = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Subtle Draggable Resize Divider on Left Edge ────────
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          onEnter: (_) => setState(() => _isHoveringHandle = true),
          onExit: (_) => setState(() => _isHoveringHandle = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => setState(() => _isDragging = true),
            onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
            onHorizontalDragCancel: () => setState(() => _isDragging = false),
            onHorizontalDragUpdate: (details) {
              widget.onResizeDelta?.call(details.delta.dx);
            },
            child: Container(
              width: 14,
              color: Colors.transparent,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: (_isDragging || _isHoveringHandle) ? 3.5 : 2.0,
                  height: (_isDragging || _isHoveringHandle) ? 56 : 36,
                  decoration: BoxDecoration(
                    color: (_isDragging || _isHoveringHandle)
                        ? widget.accent
                        : Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: (_isDragging || _isHoveringHandle)
                        ? [
                            BoxShadow(
                              color: widget.accent.withAlpha(90),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),

        // ─── Main Queue Panel ────────────────────────────────────
        Container(
          width: widget.width,
          margin: const EdgeInsets.fromLTRB(0, 8, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF130912).withAlpha(220),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withAlpha(25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 30,
                offset: const Offset(-4, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 10, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.queue_music_rounded,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Playback Queue',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.accent.withAlpha(35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.audioManager.queue.length}',
                            style: TextStyle(
                              color: widget.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (widget.audioManager.queue.isNotEmpty)
                          TextButton(
                            onPressed: () => widget.audioManager.clearQueue(),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: Colors.white70),
                          onPressed: widget.onClose,
                          tooltip: 'Close queue',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  // Queue List
                  Expanded(
                    child: _NowPlayingQueueContent(
                      audioManager: widget.audioManager,
                      accent: widget.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Animated Heart Favorite Button ───────────────────────────

class _AnimatedHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final Color accent;
  final double size;

  const _AnimatedHeartButton({
    required this.isFavorite,
    required this.onToggle,
    required this.accent,
    this.size = 22,
  });

  @override
  State<_AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<_AnimatedHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0.0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          size: widget.size,
          color: widget.isFavorite ? widget.accent : Colors.white70,
        ),
      ),
      onPressed: _handleTap,
      tooltip: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}

// ─── Now Playing Queue Content (Shared) ───────────────────────

class _NowPlayingQueueContent extends StatelessWidget {
  final AudioManager audioManager;
  final Color accent;
  final ScrollController? scrollController;

  const _NowPlayingQueueContent({
    required this.audioManager,
    required this.accent,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final queue = audioManager.queue;
    if (queue.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.queue_music_rounded,
          title: 'Queue is Empty',
          subtitle: 'Add songs from Home, Search, or Playlists.',
        ),
      );
    }

    return ReorderableListView.builder(
      scrollController: scrollController,
      buildDefaultDragHandles:
          false, // Prevents accidental reorder when tapping row to play
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: queue.length,
      // ignore: deprecated_member_use
      onReorder: (oldIndex, newIndex) {
        audioManager.reorderQueue(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(animation.value);
            return Material(
              color: Colors.transparent,
              elevation: 8 * t,
              shadowColor: Colors.black.withAlpha(160),
              child: Transform.scale(
                scale: 1.0 + (0.025 * t),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final song = queue[index];
        final isCurrent = index == audioManager.currentIndex;

        return Padding(
          key: ValueKey('queue_song_${song.id}_$index'),
          padding: const EdgeInsets.symmetric(vertical: 3.5),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(12),
            blur: isCurrent ? 14 : 6,
            backgroundColor:
                isCurrent ? accent.withAlpha(32) : Colors.white.withAlpha(8),
            borderColor:
                isCurrent ? accent.withAlpha(90) : Colors.white.withAlpha(16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                // Index or Playing indicator
                SizedBox(
                  width: 24,
                  child: isCurrent
                      ? Icon(Icons.equalizer_rounded, size: 16, color: accent)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: SonoraColors.textTertiary,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(width: 8),
                // Artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: song.artworkUrl.isNotEmpty
                        ? Image.network(
                            song.artworkUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 100,
                            errorBuilder: (_, __, ___) => Container(
                              color: SonoraColors.surfaceElevated,
                              child: const Icon(Icons.music_note,
                                  size: 16, color: SonoraColors.textTertiary),
                            ),
                          )
                        : Container(
                            color: SonoraColors.surfaceElevated,
                            child: const Icon(Icons.music_note,
                                size: 16, color: SonoraColors.textTertiary),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                // Metadata (tap to play)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => audioManager.skipToIndex(index),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            color: isCurrent ? accent : Colors.white,
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: SonoraColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Duration
                Text(
                  song.formattedDuration,
                  style: const TextStyle(
                    color: SonoraColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 2),
                // Remove button
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: Colors.white54,
                  tooltip: 'Remove',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () => audioManager.removeFromQueue(index),
                ),
                // Drag handle for reordering
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Tooltip(
                      message: 'Drag to reorder',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.drag_handle_rounded,
                          size: 18,
                          color: Colors.white.withAlpha(isCurrent ? 140 : 80),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Stylized Vinyl Record Artwork ────────────────────────────

class _VinylRecordArtwork extends StatelessWidget {
  final String artworkUrl;
  final Color accent;
  final double size;

  const _VinylRecordArtwork({
    required this.artworkUrl,
    required this.accent,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    final discCenterSize = size * 0.44;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF140810),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(50),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(160),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Concentric Vinyl Grooves
          CustomPaint(
            size: Size(size, size),
            painter: _VinylGroovesPainter(),
          ),

          // Center Album Art Disc
          ClipRRect(
            borderRadius: BorderRadius.circular(discCenterSize / 2),
            child: Container(
              width: discCenterSize,
              height: discCenterSize,
              color: SonoraColors.surfaceElevated,
              child: artworkUrl.isNotEmpty
                  ? Image.network(
                      artworkUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _discPlaceholder(),
                    )
                  : _discPlaceholder(),
            ),
          ),

          // Center Spindle Hole
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0C060A),
              border: Border.all(color: Colors.white24, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _discPlaceholder() {
    return Container(
      color: const Color(0xFF261020),
      child: Center(
        child: Icon(Icons.music_note_rounded, color: accent, size: 36),
      ),
    );
  }
}

class _VinylGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double r = 65; r < size.width / 2 - 8; r += 7) {
      canvas.drawCircle(center, r, paint);
    }

    // Outer vinyl lip
    final lipPaint = Paint()
      ..color = Colors.white.withAlpha(28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, size.width / 2 - 2, lipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Waveform Visualizer ──────────────────────────────────────

class _WaveformVisualizer extends StatelessWidget {
  final bool isPlaying;
  final Color accent;

  const _WaveformVisualizer({
    required this.isPlaying,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    // 28 static/proportional audio waveform bars
    const heights = [
      14.0,
      22.0,
      34.0,
      18.0,
      28.0,
      42.0,
      36.0,
      20.0,
      30.0,
      48.0,
      38.0,
      24.0,
      32.0,
      44.0,
      26.0,
      36.0,
      46.0,
      28.0,
      20.0,
      38.0,
      42.0,
      30.0,
      22.0,
      34.0,
      26.0,
      18.0,
      28.0,
      16.0,
    ];

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(heights.length, (i) {
          final h =
              isPlaying ? heights[i] : (heights[i] * 0.4).clamp(6.0, 48.0);
          final opacity = (i % 3 == 0) ? 0.9 : 0.55;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (i * 15)),
            width: 3.2,
            height: h,
            decoration: BoxDecoration(
              color: accent.withAlpha((opacity * 255).round()),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Queue Screen ─────────────────────────────────────────────

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  void _confirmClearQueue(BuildContext context, AudioManager audioManager) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1519),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        title: const Text('Clear Queue'),
        content:
            const Text('Are you sure you want to remove all upcoming songs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              audioManager.clearQueue();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final queue = audioManager.queue;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Playback Queue',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (queue.isNotEmpty)
              Text(
                '${queue.length} ${queue.length == 1 ? 'song' : 'songs'}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: SonoraColors.textSecondary),
              ),
          ],
        ),
        actions: [
          if (queue.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearQueue(context, audioManager),
              child: const Text(
                'Clear',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
        ],
      ),
      body: queue.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.queue_music_rounded,
                title: 'Queue is Empty',
                subtitle:
                    'Add songs to your queue from Home, Search, or Playlists.',
              ),
            )
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: queue.length,
              // ignore: deprecated_member_use
              onReorder: audioManager.reorderQueue,
              itemBuilder: (context, index) {
                final song = queue[index];
                final isCurrent = index == audioManager.currentIndex;

                return Padding(
                  key: ValueKey('${song.id}_$index'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(14),
                    blur: isCurrent ? 16 : 8,
                    backgroundColor: isCurrent
                        ? accent.withAlpha(28)
                        : Colors.white.withAlpha(8),
                    borderColor: isCurrent
                        ? accent.withAlpha(80)
                        : Colors.white.withAlpha(15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: song.artworkUrl.isNotEmpty
                              ? Image.network(
                                  song.artworkUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: SonoraColors.surfaceCard,
                                    child: const Icon(Icons.music_note,
                                        color: SonoraColors.textTertiary),
                                  ),
                                )
                              : Container(
                                  color: SonoraColors.surfaceCard,
                                  child: const Icon(Icons.music_note,
                                      color: SonoraColors.textTertiary),
                                ),
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isCurrent ? accent : Colors.white,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song.artist,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SonoraColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.formattedDuration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SonoraColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            tooltip: 'Remove',
                            onPressed: () =>
                                audioManager.removeFromQueue(index),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: Icon(
                                Icons.drag_handle_rounded,
                                size: 20,
                                color: SonoraColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => audioManager.skipToIndex(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
