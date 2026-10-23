import '../../models/playlist.dart';

/// Provides dummy playlists for UI evaluation.
///
/// These playlists reference songs from [SampleMusicProvider] by their IDs.
/// No database is created — this is purely in-memory sample data that
/// enables the glassmorphism UI to be properly evaluated.
class SamplePlaylistsProvider {
  SamplePlaylistsProvider._();

  static final List<Playlist> playlists = _buildPlaylists();

  static List<Playlist> _buildPlaylists() {
    final now = DateTime.now();
    return [
      Playlist(
        id: 'playlist_chill_vibes',
        name: 'Chill Vibes',
        description: 'Relax and unwind with the best chill tracks.',
        artworkUrl: 'https://picsum.photos/seed/chill_vibes/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 2)),
        songIds: [
          'song_04', 'song_05', 'song_06', 'song_10',
          'song_11', 'song_12', 'song_16', 'song_17',
          'song_18', 'song_02',
        ],
        isPublic: true,
      ),
      Playlist(
        id: 'playlist_workout_mix',
        name: 'Workout Mix',
        description: 'High energy tracks to power your workout.',
        artworkUrl: 'https://picsum.photos/seed/workout_mix/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 3)),
        songIds: [
          'song_01', 'song_03', 'song_07', 'song_08',
          'song_09', 'song_13', 'song_14', 'song_15',
          'song_19', 'song_20',
        ],
        isPublic: true,
      ),
      Playlist(
        id: 'playlist_late_night',
        name: 'Late Night',
        description: 'Moody tunes for late night sessions.',
        artworkUrl: 'https://picsum.photos/seed/late_night/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
        songIds: [
          'song_10', 'song_11', 'song_12', 'song_01',
          'song_02', 'song_03', 'song_16', 'song_17',
          'song_18',
        ],
        isPublic: true,
      ),
      Playlist(
        id: 'playlist_indie_favs',
        name: 'Indie Favs',
        description: 'The best indie tracks handpicked for you.',
        artworkUrl: 'https://picsum.photos/seed/indie_favs/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 1)),
        songIds: [
          'song_16', 'song_17', 'song_18', 'song_04',
          'song_05', 'song_06', 'song_02', 'song_11',
        ],
        isPublic: true,
      ),
      Playlist(
        id: 'playlist_mood_boost',
        name: 'Mood Boost',
        description: 'Feel-good music to brighten your day.',
        artworkUrl: 'https://picsum.photos/seed/mood_boost/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 4)),
        songIds: [
          'song_04', 'song_13', 'song_14', 'song_15',
          'song_01', 'song_05', 'song_08', 'song_19',
        ],
        isPublic: true,
      ),
      Playlist(
        id: 'playlist_road_trip',
        name: 'Road Trip',
        description: 'Perfect soundtrack for the open road.',
        artworkUrl: 'https://picsum.photos/seed/road_trip/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 6)),
        songIds: [
          'song_07', 'song_08', 'song_09', 'song_01',
          'song_03', 'song_13', 'song_14', 'song_19',
          'song_20',
        ],
        isPublic: true,
      ),
      Playlist(
        id: 'playlist_focus_flow',
        name: 'Focus Flow',
        description: 'Deep focus music for productivity.',
        artworkUrl: 'https://picsum.photos/seed/focus_flow/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 7)),
        songIds: [
          'song_10', 'song_11', 'song_12', 'song_16',
          'song_17', 'song_18', 'song_02', 'song_06',
        ],
        isPublic: true,
      ),
      Playlist(
        id: 'playlist_weekend_party',
        name: 'Weekend Party',
        description: 'Turn up the volume and let loose.',
        artworkUrl: 'https://picsum.photos/seed/weekend_party/400/400',
        ownerId: 'alex',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
        songIds: [
          'song_13', 'song_14', 'song_15', 'song_07',
          'song_08', 'song_09', 'song_01', 'song_03',
          'song_19', 'song_20',
        ],
        isPublic: true,
      ),
    ];
  }

  /// Get a playlist by ID.
  static Playlist? getById(String id) {
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
