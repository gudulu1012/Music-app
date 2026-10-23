import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive.dart';
import '../../services/audio/audio_manager.dart';
import '../../services/auth/auth_service.dart';
import '../../shared/widgets/mini_player.dart';
import '../../shared/widgets/desktop_mini_player.dart';
import '../../shared/widgets/desktop_side_player.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../app/router.dart';

/// The main application shell that provides:
/// - Bottom navigation (mobile) with 5 items
/// - Navigation rail (tablet)
/// - Persistent sidebar (desktop) with full nav + user profile
/// - Desktop side player (Now Playing + Queue)
/// - Persistent mini-player
/// - Responsive content area
class AppShellLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final VoidCallback? onMiniPlayerTap;
  final void Function(String route, {Object? arguments})? onNavigateTo;

  const AppShellLayout({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.onMiniPlayerTap,
    this.onNavigateTo,
  });

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final hasMiniPlayer = audioManager.hasSong;

    return ResponsiveBuilder(
      // ─── Mobile Layout ────────────────────────────────────
      mobile: (context) => _MobileLayout(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: onMiniPlayerTap,
        hasMiniPlayer: hasMiniPlayer,
        body: body,
      ),
      // ─── Tablet Layout (Navigation Rail) ──────────────────
      tablet: (context) => _TabletLayout(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: onMiniPlayerTap,
        hasMiniPlayer: hasMiniPlayer,
        body: body,
      ),
      // ─── Desktop Layout (Sidebar + Now Playing panel) ─────
      desktop: (context) => _DesktopLayout(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        onMiniPlayerTap: onMiniPlayerTap,
        onNavigateTo: onNavigateTo,
        hasMiniPlayer: hasMiniPlayer,
        body: body,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MOBILE LAYOUT
// ═══════════════════════════════════════════════════════════════

class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onMiniPlayerTap;
  final bool hasMiniPlayer;
  final Widget body;

  const _MobileLayout({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onMiniPlayerTap,
    required this.hasMiniPlayer,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: body,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasMiniPlayer) MiniPlayer(onTap: onMiniPlayerTap),
          Container(
            decoration: BoxDecoration(
              color: SonoraColors.surface.withAlpha(240),
              border: Border(
                top: BorderSide(
                  color: accent.withAlpha(30),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MobileNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      accent: accent,
                      onTap: () => onDestinationSelected(0),
                    ),
                    _MobileNavItem(
                      icon: Icons.search_outlined,
                      activeIcon: Icons.search_rounded,
                      label: 'Search',
                      isSelected: currentIndex == 1,
                      accent: accent,
                      onTap: () => onDestinationSelected(1),
                    ),
                    _MobileNavItem(
                      icon: Icons.library_music_outlined,
                      activeIcon: Icons.library_music_rounded,
                      label: 'Library',
                      isSelected: currentIndex == 2,
                      accent: accent,
                      onTap: () => onDestinationSelected(2),
                    ),
                    _MobileNavItem(
                      icon: Icons.queue_music_outlined,
                      activeIcon: Icons.queue_music_rounded,
                      label: 'Playlists',
                      isSelected: currentIndex == 3,
                      accent: accent,
                      onTap: () => onDestinationSelected(3),
                    ),
                    _MobileNavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      isSelected: currentIndex == 4,
                      accent: accent,
                      onTap: () => onDestinationSelected(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? accent : SonoraColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? accent : SonoraColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TABLET LAYOUT
// ═══════════════════════════════════════════════════════════════

class _TabletLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onMiniPlayerTap;
  final bool hasMiniPlayer;
  final Widget body;

  const _TabletLayout({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onMiniPlayerTap,
    required this.hasMiniPlayer,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: SonoraColors.surface,
              border: Border(
                right: BorderSide(
                  color: SonoraColors.surfaceBorder.withAlpha(80),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Logo
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.music_note_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(height: 24),
                // Nav items
                ..._buildRailItems(accent),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(child: body),
                if (hasMiniPlayer) MiniPlayer(onTap: onMiniPlayerTap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRailItems(Color accent) {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home', 0),
      (Icons.search_outlined, Icons.search_rounded, 'Search', 1),
      (Icons.library_music_outlined, Icons.library_music_rounded, 'Library', 2),
      (Icons.queue_music_outlined, Icons.queue_music_rounded, 'Playlists', 3),
      (Icons.settings_outlined, Icons.settings_rounded, 'Settings', 4),
    ];

    return items.map((item) {
      final isSelected = currentIndex == item.$4;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: item.$3,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onDestinationSelected(item.$4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? accent.withAlpha(25) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? item.$2 : item.$1,
                color: isSelected ? accent : SonoraColors.textTertiary,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════
// DESKTOP LAYOUT
// ═══════════════════════════════════════════════════════════════

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onMiniPlayerTap;
  final void Function(String route, {Object? arguments})? onNavigateTo;
  final bool hasMiniPlayer;
  final Widget body;

  const _DesktopLayout({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onMiniPlayerTap,
    required this.onNavigateTo,
    required this.hasMiniPlayer,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final auth = context.watch<AuthService>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Show side player only when screen is wide enough
    final showSidePlayer = screenWidth >= 1400 && hasMiniPlayer;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Sidebar ─────────────────────────────
                _DesktopSidebar(
                  currentIndex: currentIndex,
                  accent: accent,
                  auth: auth,
                  onDestinationSelected: onDestinationSelected,
                  onNavigateTo: onNavigateTo,
                ),
                // ─── Main Content ────────────────────────
                Expanded(child: body),
                // ─── Side Player ─────────────────────────
                if (showSidePlayer) const DesktopSidePlayer(),
              ],
            ),
          ),
          // ─── Bottom Mini Player (full-width on desktop) ─
          if (hasMiniPlayer)
            DesktopMiniPlayer(
              onTap: onMiniPlayerTap,
              onExpandPlayer: onMiniPlayerTap,
            ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final Color accent;
  final AuthService auth;
  final ValueChanged<int> onDestinationSelected;
  final void Function(String route, {Object? arguments})? onNavigateTo;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.accent,
    required this.auth,
    required this.onDestinationSelected,
    required this.onNavigateTo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: SonoraColors.surface,
        border: Border(
          right: BorderSide(
            color: SonoraColors.surfaceBorder.withAlpha(60),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // ─── Logo ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Icon(
                  Icons.graphic_eq_rounded,
                  color: accent,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  'Sonora',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),

          // ─── Main Navigation ───────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _SidebarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  accent: accent,
                  onTap: () => onDestinationSelected(0),
                ),
                _SidebarItem(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  isSelected: currentIndex == 1,
                  accent: accent,
                  onTap: () => onDestinationSelected(1),
                ),
                _SidebarItem(
                  icon: Icons.library_music_rounded,
                  label: 'Library',
                  isSelected: currentIndex == 2,
                  accent: accent,
                  onTap: () => onDestinationSelected(2),
                ),
                _SidebarItem(
                  icon: Icons.queue_music_rounded,
                  label: 'Playlists',
                  isSelected: currentIndex == 3,
                  accent: accent,
                  onTap: () => onDestinationSelected(3),
                ),
                const SizedBox(height: 20),
                _SidebarDivider(),
                const SizedBox(height: 12),
                _SidebarItem(
                  icon: Icons.favorite_rounded,
                  label: 'Favorites',
                  accent: accent,
                  onTap: () => onNavigateTo?.call(AppRouter.favorites),
                ),
                _SidebarItem(
                  icon: Icons.download_rounded,
                  label: 'Downloads',
                  accent: accent,
                  onTap: () => onNavigateTo?.call(AppRouter.downloads),
                ),
                _SidebarItem(
                  icon: Icons.history_rounded,
                  label: 'Recently Played',
                  accent: accent,
                  onTap: () => onNavigateTo?.call(AppRouter.recentlyPlayed),
                ),
                const SizedBox(height: 20),
                _SidebarDivider(),
                const SizedBox(height: 12),
                _SidebarItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentIndex == 4,
                  accent: accent,
                  onTap: () => onDestinationSelected(4),
                ),
              ],
            ),
          ),

          // ─── User Profile ──────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: SonoraColors.surfaceBorder.withAlpha(60),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withAlpha(40),
                  child: Text(
                    (auth.currentUser?.displayName ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.displayName ?? 'Alex',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        auth.currentUser?.email ?? 'alex@example.com',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: SonoraColors.textTertiary,
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
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.accent.withAlpha(45)
                : _isHovered
                    ? SonoraColors.surfaceElevated
                    : Colors.transparent,
            border: widget.isSelected
                ? Border.all(color: widget.accent.withAlpha(110), width: 1)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? widget.accent
                          : SonoraColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: widget.isSelected
                            ? Colors.white
                            : SonoraColors.textSecondary,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: SonoraColors.surfaceBorder.withAlpha(60),
    );
  }
}
