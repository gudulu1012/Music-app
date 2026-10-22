import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'sonora_colors.dart';

/// Manages the active Sonora theme (accent color).
///
/// Uses [SharedPreferences] as the single source of truth for the
/// selected accent theme. This avoids competing with the Firestore-backed
/// [UserSettings.accentColor] field — the ThemeProvider is UI-only
/// session persistence via local storage.
class ThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'sonora_theme';

  SonoraThemeType _currentTheme = SonoraThemeType.crimsonMinimal;
  bool _initialized = false;

  ThemeProvider() {
    _loadFromPrefs();
  }

  // ─── Getters ──────────────────────────────────────────────

  /// The currently active theme type.
  SonoraThemeType get currentTheme => _currentTheme;

  /// The full preset for the current theme.
  SonoraThemePreset get preset => SonoraColors.getPreset(_currentTheme);

  /// The primary accent color of the current theme.
  Color get accentColor => preset.primary;

  /// A darker variant of the accent color.
  Color get accentDark => preset.primaryDark;

  /// A light variant of the accent color (for subtle glows/tints).
  Color get accentLight => preset.primaryLight;

  /// Whether the provider has loaded from disk.
  bool get isInitialized => _initialized;

  // ─── Theme Switching ──────────────────────────────────────

  /// Set the active theme and persist to SharedPreferences.
  Future<void> setTheme(SonoraThemeType theme) async {
    if (_currentTheme == theme) return;
    _currentTheme = theme;
    notifyListeners();
    await _saveToPrefs();
  }

  // ─── Persistence ──────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null) {
        final parsed = SonoraThemeType.values.where(
          (t) => t.name == stored,
        );
        if (parsed.isNotEmpty) {
          _currentTheme = parsed.first;
        }
      }
    } catch (_) {
      // Fall through to default
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _currentTheme.name);
    } catch (_) {
      // Silently fail — theme will reset next session
    }
  }

  // ─── Convenience: access from context ─────────────────────

  /// Read ThemeProvider from the widget tree (does not rebuild).
  static ThemeProvider of(BuildContext context) {
    return context.read<ThemeProvider>();
  }

  /// Watch ThemeProvider from the widget tree (rebuilds on change).
  static ThemeProvider watchOf(BuildContext context) {
    return context.watch<ThemeProvider>();
  }
}
