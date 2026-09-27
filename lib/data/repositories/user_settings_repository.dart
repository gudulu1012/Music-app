import '../../models/user_settings.dart';
import '../../core/constants/app_constants.dart';
import '../firebase/firestore_service.dart';

/// Repository for user settings/preferences — synced to Firestore.
///
/// Settings are stored at: users/{uid}/settings/preferences
class UserSettingsRepository {
  final FirestoreService firestoreService;

  static const String _settingsDocId = 'preferences';

  UserSettingsRepository({required this.firestoreService});

  /// Get settings for a user. Returns defaults if none exist.
  Future<UserSettings> getSettings(String userId) async {
    final data = await firestoreService.getDocument(
      '${AppConstants.usersCollection}/$userId/${AppConstants.settingsCollection}',
      _settingsDocId,
    );
    if (data != null) {
      return UserSettings.fromMap(data);
    }
    return UserSettings(userId: userId);
  }

  /// Listen to user settings in real time.
  Stream<UserSettings> watchSettings(String userId) {
    return firestoreService
        .streamDocument(
          '${AppConstants.usersCollection}/$userId/${AppConstants.settingsCollection}',
          _settingsDocId,
        )
        .map((data) => data != null
            ? UserSettings.fromMap(data)
            : UserSettings(userId: userId));
  }

  /// Save user settings.
  Future<void> saveSettings(UserSettings settings) async {
    await firestoreService.setUserSubDocument(
      settings.userId,
      AppConstants.settingsCollection,
      _settingsDocId,
      settings.toMap(),
    );
  }

  /// Update a single setting field without overwriting other fields.
  Future<void> updateSetting(
    String userId,
    String key,
    dynamic value,
  ) async {
    await firestoreService.setUserSubDocument(
      userId,
      AppConstants.settingsCollection,
      _settingsDocId,
      {key: value},
      merge: true,
    );
  }
}
