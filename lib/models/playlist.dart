

/// Represents a user-created or system playlist.
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? artworkUrl;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> songIds;
  final bool isPublic;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.artworkUrl,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.songIds = const [],
    this.isPublic = false,
  });

  int get songCount => songIds.length;

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? artworkUrl,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? songIds,
    bool? isPublic,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songIds: songIds ?? this.songIds,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'artworkUrl': artworkUrl,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'songIds': songIds,
      'isPublic': isPublic,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      artworkUrl: map['artworkUrl'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
      songIds: List<String>.from(map['songIds'] ?? []),
      isPublic: map['isPublic'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Playlist && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
