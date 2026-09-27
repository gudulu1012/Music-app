import '../../models/song.dart';
import '../firebase/firestore_service.dart';
import '../sample_data/sample_music_provider.dart';

/// Repository for song/catalog data.
///
/// Sits between the UI and the data sources (Firestore + MusicProvider).
/// The UI always goes through this repository — never directly to
/// Firestore or the provider.
class SongRepository {
  final FirestoreService firestoreService;
  final MusicProvider musicProvider;

  SongRepository({
    required this.firestoreService,
    required this.musicProvider,
  });

  /// Fetch the full catalog from the music provider.
  Future<List<Song>> getCatalog() => musicProvider.fetchCatalog();

  /// Search songs by query.
  Future<List<Song>> searchSongs(String query) => musicProvider.search(query);

  /// Fetch a single song by ID.
  Future<Song?> getSong(String songId) => musicProvider.fetchSong(songId);

  /// Fetch multiple songs by their IDs.
  Future<List<Song>> getSongsByIds(List<String> ids) =>
      musicProvider.fetchSongsByIds(ids);
}
