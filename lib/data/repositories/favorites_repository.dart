import '../../core/constants/app_constants.dart';
import '../firebase/firestore_service.dart';

/// Repository for user favorites — synced to Firestore.
///
/// Favorites are stored at: users/{uid}/favorites/{songId}
class FavoritesRepository {
  final FirestoreService firestoreService;

  FavoritesRepository({required this.firestoreService});

  /// Get all favorite song IDs for a user.
  Future<List<String>> getFavoriteIds(String userId) async {
    final data = await firestoreService.getUserSubCollection(
      userId,
      AppConstants.favoritesCollection,
      orderByField: 'addedAt',
      descending: true,
    );
    return data.map((m) => m['songId'] as String).toList();
  }

  /// Alias for getFavoriteIds.
  Future<List<String>> getFavorites(String userId) => getFavoriteIds(userId);

  /// Listen to favorite changes in real time.
  Stream<List<String>> watchFavoriteIds(String userId) {
    return firestoreService
        .streamUserSubCollection(
          userId,
          AppConstants.favoritesCollection,
          orderByField: 'addedAt',
          descending: true,
        )
        .map((list) => list.map((m) => m['songId'] as String).toList());
  }

  /// Check if a song is favorited.
  Future<bool> isFavorite(String userId, String songId) async {
    return firestoreService.userSubDocumentExists(
      userId,
      AppConstants.favoritesCollection,
      songId,
    );
  }

  /// Add a song to favorites.
  Future<void> addFavorite(String userId, String songId) async {
    await firestoreService.setUserSubDocument(
      userId,
      AppConstants.favoritesCollection,
      songId,
      {
        'songId': songId,
        'addedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Remove a song from favorites.
  Future<void> removeFavorite(String userId, String songId) async {
    await firestoreService.deleteUserSubDocument(
      userId,
      AppConstants.favoritesCollection,
      songId,
    );
  }

  /// Toggle favorite status. Returns true if now favorited.
  Future<bool> toggleFavorite(String userId, String songId) async {
    final isFav = await isFavorite(userId, songId);
    if (isFav) {
      await removeFavorite(userId, songId);
      return false;
    } else {
      await addFavorite(userId, songId);
      return true;
    }
  }
}
