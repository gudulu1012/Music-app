import '../../models/song.dart';

/// Provides the sample/test music catalog.
///
/// This is the ONLY music source during Phase 1.
/// It will be replaced by a real [MusicProvider] implementation
/// in a later phase. All audio URLs point to legal, royalty-free
/// sample tracks hosted publicly.
///
/// The provider interface is deliberately simple so that swapping
/// in the real implementation later requires minimal changes.
abstract class MusicProvider {
  /// Fetch the full catalog of available songs.
  Future<List<Song>> fetchCatalog();

  /// Search the catalog by query string.
  Future<List<Song>> search(String query);

  /// Fetch a single song by ID.
  Future<Song?> fetchSong(String songId);

  /// Fetch songs by a list of IDs (for loading playlists, etc.).
  Future<List<Song>> fetchSongsByIds(List<String> ids);
}

class SampleMusicProvider implements MusicProvider {
  // Legal sample audio URLs from the Internet Archive and similar sources.
  // These are royalty-free/CC0 tracks for development/testing only.
  static const _sampleAudioBase =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-';

  late final List<Song> _catalog;

  SampleMusicProvider() {
    _catalog = _buildCatalog();
  }

  List<Song> _buildCatalog() {
    final now = DateTime.now();
    return [
      Song(
        id: 'song_01',
        title: 'Midnight Drive',
        artist: 'Neon Pulse',
        album: 'Synthwave Dreams',
        artworkUrl: 'https://picsum.photos/seed/album1/300/300',
        duration: const Duration(minutes: 4, seconds: 23),
        streamUrl: '${_sampleAudioBase}1.mp3',
        createdAt: now.subtract(const Duration(days: 30)),
        genre: 'Electronic',
        trackNumber: 1,
      ),
      Song(
        id: 'song_02',
        title: 'Crystal Waves',
        artist: 'Aurora Keys',
        album: 'Synthwave Dreams',
        artworkUrl: 'https://picsum.photos/seed/album1/300/300',
        duration: const Duration(minutes: 3, seconds: 45),
        streamUrl: '${_sampleAudioBase}2.mp3',
        createdAt: now.subtract(const Duration(days: 29)),
        genre: 'Electronic',
        trackNumber: 2,
      ),
      Song(
        id: 'song_03',
        title: 'Velvet Horizon',
        artist: 'Neon Pulse',
        album: 'Synthwave Dreams',
        artworkUrl: 'https://picsum.photos/seed/album1/300/300',
        duration: const Duration(minutes: 5, seconds: 12),
        streamUrl: '${_sampleAudioBase}3.mp3',
        createdAt: now.subtract(const Duration(days: 28)),
        genre: 'Electronic',
        trackNumber: 3,
      ),
      Song(
        id: 'song_04',
        title: 'Golden Hour',
        artist: 'Sunset Boulevard',
        album: 'Warm Tones',
        artworkUrl: 'https://picsum.photos/seed/album2/300/300',
        duration: const Duration(minutes: 3, seconds: 56),
        streamUrl: '${_sampleAudioBase}4.mp3',
        createdAt: now.subtract(const Duration(days: 25)),
        genre: 'Chillout',
        trackNumber: 1,
      ),
      Song(
        id: 'song_05',
        title: 'Amber Skies',
        artist: 'Sunset Boulevard',
        album: 'Warm Tones',
        artworkUrl: 'https://picsum.photos/seed/album2/300/300',
        duration: const Duration(minutes: 4, seconds: 10),
        streamUrl: '${_sampleAudioBase}5.mp3',
        createdAt: now.subtract(const Duration(days: 24)),
        genre: 'Chillout',
        trackNumber: 2,
      ),
      Song(
        id: 'song_06',
        title: 'Ocean Breeze',
        artist: 'Sunset Boulevard',
        album: 'Warm Tones',
        artworkUrl: 'https://picsum.photos/seed/album2/300/300',
        duration: const Duration(minutes: 3, seconds: 33),
        streamUrl: '${_sampleAudioBase}6.mp3',
        createdAt: now.subtract(const Duration(days: 23)),
        genre: 'Chillout',
        trackNumber: 3,
      ),
      Song(
        id: 'song_07',
        title: 'Urban Echoes',
        artist: 'Metro Collective',
        album: 'City Lights',
        artworkUrl: 'https://picsum.photos/seed/album3/300/300',
        duration: const Duration(minutes: 4, seconds: 45),
        streamUrl: '${_sampleAudioBase}7.mp3',
        createdAt: now.subtract(const Duration(days: 20)),
        genre: 'Hip Hop',
        trackNumber: 1,
      ),
      Song(
        id: 'song_08',
        title: 'Neon Streets',
        artist: 'Metro Collective',
        album: 'City Lights',
        artworkUrl: 'https://picsum.photos/seed/album3/300/300',
        duration: const Duration(minutes: 3, seconds: 28),
        streamUrl: '${_sampleAudioBase}8.mp3',
        createdAt: now.subtract(const Duration(days: 19)),
        genre: 'Hip Hop',
        trackNumber: 2,
      ),
      Song(
        id: 'song_09',
        title: 'Downtown Flow',
        artist: 'Metro Collective',
        album: 'City Lights',
        artworkUrl: 'https://picsum.photos/seed/album3/300/300',
        duration: const Duration(minutes: 5, seconds: 1),
        streamUrl: '${_sampleAudioBase}9.mp3',
        createdAt: now.subtract(const Duration(days: 18)),
        genre: 'Hip Hop',
        trackNumber: 3,
      ),
      Song(
        id: 'song_10',
        title: 'Starfall',
        artist: 'Luna Echo',
        album: 'Cosmic Journey',
        artworkUrl: 'https://picsum.photos/seed/album4/300/300',
        duration: const Duration(minutes: 6, seconds: 15),
        streamUrl: '${_sampleAudioBase}10.mp3',
        createdAt: now.subtract(const Duration(days: 15)),
        genre: 'Ambient',
        trackNumber: 1,
      ),
      Song(
        id: 'song_11',
        title: 'Nebula Dreams',
        artist: 'Luna Echo',
        album: 'Cosmic Journey',
        artworkUrl: 'https://picsum.photos/seed/album4/300/300',
        duration: const Duration(minutes: 4, seconds: 50),
        streamUrl: '${_sampleAudioBase}11.mp3',
        createdAt: now.subtract(const Duration(days: 14)),
        genre: 'Ambient',
        trackNumber: 2,
      ),
      Song(
        id: 'song_12',
        title: 'Solar Wind',
        artist: 'Luna Echo',
        album: 'Cosmic Journey',
        artworkUrl: 'https://picsum.photos/seed/album4/300/300',
        duration: const Duration(minutes: 5, seconds: 30),
        streamUrl: '${_sampleAudioBase}12.mp3',
        createdAt: now.subtract(const Duration(days: 13)),
        genre: 'Ambient',
        trackNumber: 3,
      ),
      Song(
        id: 'song_13',
        title: 'Electric Soul',
        artist: 'Rhythm Factory',
        album: 'Beat Machine',
        artworkUrl: 'https://picsum.photos/seed/album5/300/300',
        duration: const Duration(minutes: 3, seconds: 18),
        streamUrl: '${_sampleAudioBase}13.mp3',
        createdAt: now.subtract(const Duration(days: 10)),
        genre: 'Dance',
        trackNumber: 1,
      ),
      Song(
        id: 'song_14',
        title: 'Bassline Theory',
        artist: 'Rhythm Factory',
        album: 'Beat Machine',
        artworkUrl: 'https://picsum.photos/seed/album5/300/300',
        duration: const Duration(minutes: 4, seconds: 5),
        streamUrl: '${_sampleAudioBase}14.mp3',
        createdAt: now.subtract(const Duration(days: 9)),
        genre: 'Dance',
        trackNumber: 2,
      ),
      Song(
        id: 'song_15',
        title: 'Groove Engine',
        artist: 'Rhythm Factory',
        album: 'Beat Machine',
        artworkUrl: 'https://picsum.photos/seed/album5/300/300',
        duration: const Duration(minutes: 3, seconds: 42),
        streamUrl: '${_sampleAudioBase}15.mp3',
        createdAt: now.subtract(const Duration(days: 8)),
        genre: 'Dance',
        trackNumber: 3,
      ),
      Song(
        id: 'song_16',
        title: 'Morning Dew',
        artist: 'Acoustic Garden',
        album: 'Natural Vibes',
        artworkUrl: 'https://picsum.photos/seed/album6/300/300',
        duration: const Duration(minutes: 3, seconds: 55),
        streamUrl: '${_sampleAudioBase}16.mp3',
        createdAt: now.subtract(const Duration(days: 5)),
        genre: 'Acoustic',
        trackNumber: 1,
      ),
      Song(
        id: 'song_17',
        title: 'Willow Creek',
        artist: 'Acoustic Garden',
        album: 'Natural Vibes',
        artworkUrl: 'https://picsum.photos/seed/album6/300/300',
        duration: const Duration(minutes: 4, seconds: 20),
        streamUrl: '${_sampleAudioBase}1.mp3',
        createdAt: now.subtract(const Duration(days: 4)),
        genre: 'Acoustic',
        trackNumber: 2,
      ),
      Song(
        id: 'song_18',
        title: 'Raindrop Serenade',
        artist: 'Acoustic Garden',
        album: 'Natural Vibes',
        artworkUrl: 'https://picsum.photos/seed/album6/300/300',
        duration: const Duration(minutes: 5, seconds: 8),
        streamUrl: '${_sampleAudioBase}2.mp3',
        createdAt: now.subtract(const Duration(days: 3)),
        genre: 'Acoustic',
        trackNumber: 3,
      ),
      Song(
        id: 'song_19',
        title: 'Digital Pulse',
        artist: 'Neon Pulse',
        album: 'Future State',
        artworkUrl: 'https://picsum.photos/seed/album7/300/300',
        duration: const Duration(minutes: 4, seconds: 38),
        streamUrl: '${_sampleAudioBase}3.mp3',
        createdAt: now.subtract(const Duration(days: 2)),
        genre: 'Electronic',
        trackNumber: 1,
      ),
      Song(
        id: 'song_20',
        title: 'Quantum Leap',
        artist: 'Neon Pulse',
        album: 'Future State',
        artworkUrl: 'https://picsum.photos/seed/album7/300/300',
        duration: const Duration(minutes: 5, seconds: 25),
        streamUrl: '${_sampleAudioBase}4.mp3',
        createdAt: now.subtract(const Duration(days: 1)),
        genre: 'Electronic',
        trackNumber: 2,
      ),
    ];
  }

  @override
  Future<List<Song>> fetchCatalog() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_catalog);
  }

  @override
  Future<List<Song>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.toLowerCase();
    return _catalog.where((song) {
      return song.title.toLowerCase().contains(q) ||
          song.artist.toLowerCase().contains(q) ||
          song.album.toLowerCase().contains(q) ||
          (song.genre?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Future<Song?> fetchSong(String songId) async {
    try {
      return _catalog.firstWhere((s) => s.id == songId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Song>> fetchSongsByIds(List<String> ids) async {
    return _catalog.where((s) => ids.contains(s.id)).toList();
  }

  /// Get all unique albums as (albumName, artist, artworkUrl) triples.
  List<({String name, String artist, String artworkUrl})> get albums {
    final seen = <String>{};
    final result = <({String name, String artist, String artworkUrl})>[];
    for (final song in _catalog) {
      if (seen.add(song.album)) {
        result.add((
          name: song.album,
          artist: song.artist,
          artworkUrl: song.artworkUrl,
        ));
      }
    }
    return result;
  }

  /// Get all unique artist names.
  List<String> get artists {
    return _catalog.map((s) => s.artist).toSet().toList();
  }

  /// Get songs by album name.
  List<Song> songsByAlbum(String albumName) {
    return _catalog.where((s) => s.album == albumName).toList()
      ..sort((a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0));
  }

  /// Get songs by artist name.
  List<Song> songsByArtist(String artistName) {
    return _catalog.where((s) => s.artist == artistName).toList();
  }
}
