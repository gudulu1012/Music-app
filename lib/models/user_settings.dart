/// User-configurable application settings, synced to Firestore.
class UserSettings {
  final String userId;
  final bool darkMode;
  final String accentColor;
  final double volume;
  final bool crossfadeEnabled;
  final int crossfadeDuration; // seconds
  final String audioQuality; // 'low', 'medium', 'high'
  final bool autoPlay;
  final bool showExplicitContent;
  final bool downloadOverWifiOnly;

  const UserSettings({
    required this.userId,
    this.darkMode = true,
    this.accentColor = 'purple',
    this.volume = 1.0,
    this.crossfadeEnabled = false,
    this.crossfadeDuration = 5,
    this.audioQuality = 'high',
    this.autoPlay = true,
    this.showExplicitContent = true,
    this.downloadOverWifiOnly = true,
  });

  UserSettings copyWith({
    String? userId,
    bool? darkMode,
    String? accentColor,
    double? volume,
    bool? crossfadeEnabled,
    int? crossfadeDuration,
    String? audioQuality,
    bool? autoPlay,
    bool? showExplicitContent,
    bool? downloadOverWifiOnly,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      darkMode: darkMode ?? this.darkMode,
      accentColor: accentColor ?? this.accentColor,
      volume: volume ?? this.volume,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      audioQuality: audioQuality ?? this.audioQuality,
      autoPlay: autoPlay ?? this.autoPlay,
      showExplicitContent: showExplicitContent ?? this.showExplicitContent,
      downloadOverWifiOnly: downloadOverWifiOnly ?? this.downloadOverWifiOnly,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'darkMode': darkMode,
      'accentColor': accentColor,
      'volume': volume,
      'crossfadeEnabled': crossfadeEnabled,
      'crossfadeDuration': crossfadeDuration,
      'audioQuality': audioQuality,
      'autoPlay': autoPlay,
      'showExplicitContent': showExplicitContent,
      'downloadOverWifiOnly': downloadOverWifiOnly,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['userId'] as String? ?? '',
      darkMode: map['darkMode'] as bool? ?? true,
      accentColor: map['accentColor'] as String? ?? 'purple',
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      crossfadeEnabled: map['crossfadeEnabled'] as bool? ?? false,
      crossfadeDuration: map['crossfadeDuration'] as int? ?? 5,
      audioQuality: map['audioQuality'] as String? ?? 'high',
      autoPlay: map['autoPlay'] as bool? ?? true,
      showExplicitContent: map['showExplicitContent'] as bool? ?? true,
      downloadOverWifiOnly: map['downloadOverWifiOnly'] as bool? ?? true,
    );
  }
}
