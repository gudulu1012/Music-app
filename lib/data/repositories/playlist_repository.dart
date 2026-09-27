import '../../models/playlist.dart';
import '../../core/constants/app_constants.dart';
import '../firebase/firestore_service.dart';

/// Repository for user playlists — synced to Firestore.
class PlaylistRepository {
  final FirestoreService firestoreService;

  PlaylistRepository({required this.firestoreService});

  /// Get all playlists for a user.
  Future<List<Playlist>> getUserPlaylists(String userId) async {
    final data = await firestoreService.getUserSubCollection(
      userId,
      AppConstants.playlistsCollection,
      orderByField: 'updatedAt',
      descending: true,
    );
    return data.map((m) => Playlist.fromMap(m)).toList();
  }

  /// Listen to user playlists in real time.
  Stream<List<Playlist>> watchUserPlaylists(String userId) {
    return firestoreService
        .streamUserSubCollection(
          userId,
          AppConstants.playlistsCollection,
          orderByField: 'updatedAt',
          descending: true,
        )
        .map((list) => list.map((m) => Playlist.fromMap(m)).toList());
  }

  /// Get a single playlist.
  Future<Playlist?> getPlaylist(String userId, String playlistId) async {
    final data = await firestoreService.getDocument(
      '${AppConstants.usersCollection}/$userId/${AppConstants.playlistsCollection}',
      playlistId,
    );
    return data != null ? Playlist.fromMap(data) : null;
  }

  /// Save (create or update) a playlist.
  Future<void> savePlaylist(String userId, Playlist playlist) async {
    await firestoreService.setUserSubDocument(
      userId,
      AppConstants.playlistsCollection,
      playlist.id,
      playlist.toMap(),
    );
  }

  /// Create a new playlist.
  Future<void> createPlaylist(String userId, Playlist playlist) async {
    await savePlaylist(userId, playlist);
  }

  /// Update an existing playlist.
  Future<void> updatePlaylist(String userId, Playlist playlist) async {
    final updated = playlist.copyWith(updatedAt: DateTime.now());
    await savePlaylist(userId, updated);
  }

  /// Delete a playlist.
  Future<void> deletePlaylist(String userId, String playlistId) async {
    await firestoreService.deleteUserSubDocument(
      userId,
      AppConstants.playlistsCollection,
      playlistId,
    );
  }

  /// Add a song to a playlist.
  Future<void> addSongToPlaylist(
    String userId,
    String playlistId,
    String songId,
  ) async {
    final playlist = await getPlaylist(userId, playlistId);
    if (playlist != null && !playlist.songIds.contains(songId)) {
      final updated = playlist.copyWith(
        songIds: [...playlist.songIds, songId],
        updatedAt: DateTime.now(),
      );
      await savePlaylist(userId, updated);
    }
  }

  /// Remove a song from a playlist.
  Future<void> removeSongFromPlaylist(
    String userId,
    String playlistId,
    String songId,
  ) async {
    final playlist = await getPlaylist(userId, playlistId);
    if (playlist != null) {
      final updated = playlist.copyWith(
        songIds: playlist.songIds.where((id) => id != songId).toList(),
        updatedAt: DateTime.now(),
      );
      await savePlaylist(userId, updated);
    }
  }

  /// Reorder songs within a playlist and persist new order.
  Future<void> reorderSongs(
    String userId,
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final playlist = await getPlaylist(userId, playlistId);
    if (playlist != null) {
      final songs = List<String>.from(playlist.songIds);
      if (oldIndex < 0 || oldIndex >= songs.length) return;
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final song = songs.removeAt(oldIndex);
      songs.insert(newIndex.clamp(0, songs.length), song);
      final updated = playlist.copyWith(
        songIds: songs,
        updatedAt: DateTime.now(),
      );
      await savePlaylist(userId, updated);
    }
  }
}
