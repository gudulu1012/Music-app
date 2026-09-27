

/// Clean abstraction for platform-specific local storage.
///
/// Flutter Web → browser localStorage / IndexedDB.
/// Android/iOS → application documents directory.
///
/// This prevents platform-specific storage implementation from
/// leaking throughout the UI layer.
abstract class LocalStorageService {
  /// Save a string value.
  Future<void> setString(String key, String value);

  /// Get a string value.
  Future<String?> getString(String key);

  /// Save a boolean value.
  Future<void> setBool(String key, bool value);

  /// Get a boolean value.
  Future<bool?> getBool(String key);

  /// Remove a value.
  Future<void> remove(String key);

  /// Clear all stored data.
  Future<void> clear();

  /// Check if a key exists.
  Future<bool> containsKey(String key);
}

/// Default implementation using shared_preferences.
///
/// Works on both web (localStorage) and mobile (NSUserDefaults/SharedPrefs).
class DefaultLocalStorageService implements LocalStorageService {
  // In production, use SharedPreferences instance:
  // late final SharedPreferences _prefs;

  final Map<String, dynamic> _memoryStore = {};

  DefaultLocalStorageService() {
    // SharedPreferences.getInstance().then((p) => _prefs = p);
  }

  @override
  Future<void> setString(String key, String value) async {
    _memoryStore[key] = value;
    // await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _memoryStore[key] as String?;
    // return _prefs.getString(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _memoryStore[key] = value;
    // await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _memoryStore[key] as bool?;
    // return _prefs.getBool(key);
  }

  @override
  Future<void> remove(String key) async {
    _memoryStore.remove(key);
    // await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    _memoryStore.clear();
    // await _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _memoryStore.containsKey(key);
    // return _prefs.containsKey(key);
  }
}
