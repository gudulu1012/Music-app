import '../../core/constants/app_constants.dart';
import '../firebase/firestore_service.dart';

/// Repository for recently played / listening history — synced to Firestore.
///
/// History entries are stored at: users/{uid}/history/{historyId}
class HistoryRepository {
  final FirestoreService firestoreService;

  HistoryRepository({required this.firestoreService});

  /// Get the user's recently played song IDs (newest first).
  Future<List<String>> getRecentlyPlayed(
    String userId, {
    int limit = 50,
  }) async {
    final data = await firestoreService.getUserSubCollection(
      userId,
      AppConstants.historyCollection,
      orderByField: 'playedAt',
      descending: true,
      limit: limit,
    );
    return data.map((m) => m['songId'] as String).toList();
  }

  /// Alias for getRecentlyPlayed.
  Future<List<String>> getRecentHistory(
    String userId, {
    int limit = 50,
  }) =>
      getRecentlyPlayed(userId, limit: limit);

  /// Get the full history entries (with timestamps).
  Future<List<Map<String, dynamic>>> getHistoryEntries(
    String userId, {
    int limit = 50,
  }) async {
    return firestoreService.getUserSubCollection(
      userId,
      AppConstants.historyCollection,
      orderByField: 'playedAt',
      descending: true,
      limit: limit,
    );
  }

  /// Record a song play.
  Future<void> addToHistory(String userId, String songId) async {
    final entryId = '${songId}_${DateTime.now().millisecondsSinceEpoch}';
    await firestoreService.setUserSubDocument(
      userId,
      AppConstants.historyCollection,
      entryId,
      {
        'songId': songId,
        'playedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Alias for addToHistory.
  Future<void> addHistoryEntry(String userId, String songId) =>
      addToHistory(userId, songId);

  /// Clear all history for a user.
  Future<void> clearHistory(String userId) async {
    await firestoreService.deleteUserSubCollection(
      userId,
      AppConstants.historyCollection,
    );
  }
}
