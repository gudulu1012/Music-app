import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/search/search_screen.dart';
import '../features/library/library_screen.dart';
import '../features/library/library_sub_screens.dart';
import '../features/playlists/playlists_screens.dart';
import '../features/player/now_playing_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/layouts/app_shell_layout.dart';

/// Centralized routing for the entire application.
///
/// Uses a simple Navigator-based approach with named routes.
/// This can be upgraded to go_router for deep linking / web URLs later.
class AppRouter {
  AppRouter._();

  // Route names
  static const String home = '/';
  static const String search = '/search';
  static const String library = '/library';
  static const String settings = '/settings';
  static const String nowPlaying = '/now-playing';
  static const String queue = '/queue';
  static const String favorites = '/favorites';
  static const String recentlyPlayed = '/recently-played';
  static const String downloads = '/downloads';
  static const String playlists = '/playlists';
  static const String playlistDetail = '/playlist';
  static const String albumDetail = '/album';
  static const String artistDetail = '/artist';

  /// Generate a route for the given [RouteSettings].
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case nowPlaying:
        return MaterialPageRoute(
          builder: (_) => const NowPlayingScreen(),
          fullscreenDialog: true,
        );
      case queue:
        return MaterialPageRoute(builder: (_) => const QueueScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case recentlyPlayed:
        return MaterialPageRoute(builder: (_) => const RecentlyPlayedScreen());
      case downloads:
        return MaterialPageRoute(builder: (_) => const DownloadsScreen());
      case playlists:
        return MaterialPageRoute(builder: (_) => const PlaylistsScreen());
      case playlistDetail:
        final playlistId = routeSettings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => PlaylistDetailScreen(playlistId: playlistId),
        );
      case albumDetail:
        final albumName = routeSettings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => AlbumDetailScreen(albumName: albumName),
        );
      case artistDetail:
        final artistName = routeSettings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ArtistDetailScreen(artistName: artistName),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}

/// The main app shell with tab navigation.
///
/// This widget manages the bottom nav / sidebar state and hosts
/// each tab's content area with its own navigation stack.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Each tab gets its own GlobalKey so its navigation state persists.
  final _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  void _onTabSelected(int index) {
    if (index == _currentIndex) {
      // Pop to root of current tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _openNowPlaying() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NowPlayingScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      currentIndex: _currentIndex,
      onDestinationSelected: _onTabSelected,
      onMiniPlayerTap: _openNowPlaying,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _TabNavigator(
            navigatorKey: _navigatorKeys[0],
            builder: (_) => const HomeScreen(),
          ),
          _TabNavigator(
            navigatorKey: _navigatorKeys[1],
            builder: (_) => const SearchScreen(),
          ),
          _TabNavigator(
            navigatorKey: _navigatorKeys[2],
            builder: (_) => LibraryScreen(
              onNavigateToFavorites: () {
                Navigator.of(context).pushNamed(AppRouter.favorites);
              },
              onNavigateToRecentlyPlayed: () {
                Navigator.of(context).pushNamed(AppRouter.recentlyPlayed);
              },
              onNavigateToDownloads: () {
                Navigator.of(context).pushNamed(AppRouter.downloads);
              },
              onNavigateToPlaylists: () {
                Navigator.of(context).pushNamed(AppRouter.playlists);
              },
            ),
          ),
          _TabNavigator(
            navigatorKey: _navigatorKeys[3],
            builder: (_) => const SettingsScreen(),
          ),
        ],
      ),
    );
  }
}

/// Wraps each tab in its own Navigator for independent navigation stacks.
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder builder;

  const _TabNavigator({
    required this.navigatorKey,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: builder);
        }
        return AppRouter.generateRoute(settings);
      },
    );
  }
}
