import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive.dart';
import '../../services/audio/audio_manager.dart';
import '../../shared/widgets/mini_player.dart';
import '../../app/theme/app_theme.dart';

/// The main application shell that provides:
/// - Bottom navigation (mobile)
/// - Navigation rail (tablet)
/// - Sidebar (desktop)
/// - Persistent mini-player
/// - Responsive content area
class AppShellLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final VoidCallback? onMiniPlayerTap;

  const AppShellLayout({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.onMiniPlayerTap,
  });

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music_rounded),
      label: 'Library',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  static const List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search_rounded),
      label: Text('Search'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music_rounded),
      label: Text('Library'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final audioManager = context.watch<AudioManager>();
    final hasMiniPlayer = audioManager.hasSong;

    return ResponsiveBuilder(
      // ─── Mobile Layout ────────────────────────────────────
      mobile: (context) => Scaffold(
        body: body,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasMiniPlayer)
              MiniPlayer(onTap: onMiniPlayerTap),
            NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: _destinations,
            ),
          ],
        ),
      ),
      // ─── Tablet Layout (Navigation Rail) ──────────────────
      tablet: (context) => Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: _railDestinations,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Icon(
                  Icons.music_note_rounded,
                  color: AppTheme.primaryPurple,
                  size: 32,
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: body),
                  if (hasMiniPlayer)
                    MiniPlayer(onTap: onMiniPlayerTap),
                ],
              ),
            ),
          ],
        ),
      ),
      // ─── Desktop Layout (Sidebar) ─────────────────────────
      desktop: (context) => Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 240,
              color: AppTheme.darkSurface,
              child: Column(
                children: [
                  // Logo area
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.music_note_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Music App',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Navigation items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      children: [
                        _SidebarItem(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          isSelected: currentIndex == 0,
                          onTap: () => onDestinationSelected(0),
                        ),
                        _SidebarItem(
                          icon: Icons.search_rounded,
                          label: 'Search',
                          isSelected: currentIndex == 1,
                          onTap: () => onDestinationSelected(1),
                        ),
                        _SidebarItem(
                          icon: Icons.library_music_rounded,
                          label: 'Library',
                          isSelected: currentIndex == 2,
                          onTap: () => onDestinationSelected(2),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Text(
                            'YOUR LIBRARY',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(letterSpacing: 1.2),
                          ),
                        ),
                        _SidebarItem(
                          icon: Icons.favorite_rounded,
                          label: 'Favorites',
                          onTap: () {}, // TODO: Navigate to favorites
                        ),
                        _SidebarItem(
                          icon: Icons.history_rounded,
                          label: 'Recently Played',
                          onTap: () {}, // TODO: Navigate
                        ),
                        _SidebarItem(
                          icon: Icons.download_rounded,
                          label: 'Downloads',
                          onTap: () {}, // TODO: Navigate
                        ),
                        _SidebarItem(
                          icon: Icons.queue_music_rounded,
                          label: 'Playlists',
                          onTap: () {}, // TODO: Navigate
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        _SidebarItem(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          isSelected: currentIndex == 3,
                          onTap: () => onDestinationSelected(3),
                        ),
                      ],
                    ),
                  ),
                  // Mini player in sidebar
                  if (hasMiniPlayer)
                    MiniPlayer(onTap: onMiniPlayerTap),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            // Main content
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryPurple : AppTheme.darkTextSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? AppTheme.primaryPurple
                    : AppTheme.darkTextSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryPurple.withAlpha(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
        onTap: onTap,
      ),
    );
  }
}
