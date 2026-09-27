/// Core data model representing a song/track in the application.
///
/// This model is used throughout the app — in the player, playlists,
/// favorites, search results, and the catalog. It is designed to be
/// provider-agnostic so the underlying music source can be swapped
/// without touching UI code.
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String artworkUrl;
  final Duration duration;
  final String streamUrl;
  final String? localFilePath;
  final bool isDownloaded;
  final DateTime createdAt;
  final String? genre;
  final int? trackNumber;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkUrl,
    required this.duration,
    required this.streamUrl,
    this.localFilePath,
    this.isDownloaded = false,
    required this.createdAt,
    this.genre,
    this.trackNumber,
  });

  /// Create a copy with optional field overrides.
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
    String? streamUrl,
    String? localFilePath,
    bool? isDownloaded,
    DateTime? createdAt,
    String? genre,
    int? trackNumber,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      streamUrl: streamUrl ?? this.streamUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      createdAt: createdAt ?? this.createdAt,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
    );
  }

  /// Serialize to a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'artworkUrl': artworkUrl,
      'durationMs': duration.inMilliseconds,
      'streamUrl': streamUrl,
      'localFilePath': localFilePath,
      'isDownloaded': isDownloaded,
      'createdAt': createdAt.toIso8601String(),
      'genre': genre,
      'trackNumber': trackNumber,
    };
  }

  /// Deserialize from a Firestore Map.
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      artworkUrl: map['artworkUrl'] as String? ?? '',
      duration: Duration(milliseconds: map['durationMs'] as int? ?? 0),
      streamUrl: map['streamUrl'] as String? ?? '',
      localFilePath: map['localFilePath'] as String?,
      isDownloaded: map['isDownloaded'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      genre: map['genre'] as String?,
      trackNumber: map['trackNumber'] as int?,
    );
  }

  /// The effective playback URL — prefers local file if downloaded.
  String get playbackUrl => isDownloaded && localFilePath != null
      ? localFilePath!
      : streamUrl;

  /// Formatted duration string (e.g. "3:45").
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
