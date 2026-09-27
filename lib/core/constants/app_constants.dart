/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Music App';
  static const String appVersion = '1.0.0';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String playlistsCollection = 'playlists';
  static const String favoritesCollection = 'favorites';
  static const String historyCollection = 'history';
  static const String settingsCollection = 'settings';
  static const String songsCollection = 'songs';

  // Pagination
  static const int defaultPageSize = 20;
  static const int historyLimit = 100;

  // Audio
  static const int maxQueueSize = 500;
  static const int seekStepMs = 10000; // 10 seconds

  // Downloads
  static const String downloadDirectory = 'music_downloads';
  static const int maxConcurrentDownloads = 3;

  // Cache
  static const int artworkCacheMaxAge = 7; // days
  static const int maxCachedArtworks = 200;
}
