import 'package:flutter/material.dart';

/// The four available Sonora accent themes.
enum SonoraThemeType {
  crimsonMinimal,
  emeraldDark,
  amberWarm,
  slateBlue,
  pinkGlass,
}

/// Color preset for a single Sonora theme.
class SonoraThemePreset {
  final SonoraThemeType type;
  final String name;
  final String description;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color surfaceTint;

  const SonoraThemePreset({
    required this.type,
    required this.name,
    required this.description,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.surfaceTint,
  });
}

/// Centralized color system for the Sonora Music App.
///
/// All dark surfaces are shared across themes; only accent colors change.
class SonoraColors {
  SonoraColors._();

  // ─── Dark Surface Palette (shared across all themes) ──────
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF1E1E1E);
  static const Color surfaceCard = Color(0xFF161616);
  static const Color surfaceBorder = Color(0xFF2A2A2A);
  static const Color surfaceGlass = Color(0x33FFFFFF);

  // ─── Text Colors ──────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F1F3);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);

  // ─── Semantic Colors ──────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // ─── Theme Presets ────────────────────────────────────────
  static const List<SonoraThemePreset> presets = [
    SonoraThemePreset(
      type: SonoraThemeType.crimsonMinimal,
      name: 'Crimson Minimal',
      description:
          'Bold, modern and cinematic. Perfect for a premium music experience.',
      primary: Color(0xFFEF4444),
      primaryDark: Color(0xFF9B0B0F),
      primaryLight: Color(0xFFE5E7EB),
      surfaceTint: Color(0xFF1B1B1B),
    ),
    SonoraThemePreset(
      type: SonoraThemeType.emeraldDark,
      name: 'Emerald Dark',
      description:
          'Clean, sophisticated and refreshing. A premium look with a calm vibe.',
      primary: Color(0xFF10B981),
      primaryDark: Color(0xFF0A6F4E),
      primaryLight: Color(0xFF111B27),
      surfaceTint: Color(0xFF0A0F0E),
    ),
    SonoraThemePreset(
      type: SonoraThemeType.amberWarm,
      name: 'Amber Warm',
      description: 'Rich, warm and premium. Gives a cozy yet modern feel.',
      primary: Color(0xFFF59E0B),
      primaryDark: Color(0xFF8D5B0F),
      primaryLight: Color(0xFFFDE68A),
      surfaceTint: Color(0xFF1F1F23),
    ),
    SonoraThemePreset(
      type: SonoraThemeType.slateBlue,
      name: 'Slate Blue',
      description:
          'Modern, sleek and elegant. A subtle and professional aesthetic.',
      primary: Color(0xFF3B82F6),
      primaryDark: Color(0xFF1E40AF),
      primaryLight: Color(0xFFE0E7FF),
      surfaceTint: Color(0xFF0A0F1A),
    ),
    SonoraThemePreset(
      type: SonoraThemeType.pinkGlass,
      name: 'Pink Glass',
      description:
          'Cinematic ruby & rose glow with deep burgundy frosted glass.',
      primary: Color(0xFFF29AB5),
      primaryDark: Color(0xFFD20D3A),
      primaryLight: Color(0xFFFFE5EC),
      surfaceTint: Color(0xFF28040B),
    ),
  ];

  /// Get a preset by type.
  static SonoraThemePreset getPreset(SonoraThemeType type) {
    return presets.firstWhere((p) => p.type == type);
  }
}
