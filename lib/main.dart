import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'services/auth/auth_service.dart';
import 'services/audio/audio_manager.dart';
import 'services/downloads/download_manager.dart';
import 'data/repositories/song_repository.dart';
import 'data/repositories/playlist_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/user_settings_repository.dart';
import 'data/firebase/firestore_service.dart';
import 'data/sample_data/sample_music_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestoreService = FirestoreService();
  final authService = AuthService(firestoreService: firestoreService);
  final audioManager = AudioManager();
  final downloadManager = DownloadManager();
  final musicProvider = SampleMusicProvider();

  final songRepository = SongRepository(
    firestoreService: firestoreService,
    musicProvider: musicProvider,
  );
  final playlistRepository = PlaylistRepository(
    firestoreService: firestoreService,
  );
  final favoritesRepository = FavoritesRepository(
    firestoreService: firestoreService,
  );
  final historyRepository = HistoryRepository(
    firestoreService: firestoreService,
  );
  final userSettingsRepository = UserSettingsRepository(
    firestoreService: firestoreService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: audioManager),
        ChangeNotifierProvider.value(value: downloadManager),
        Provider.value(value: songRepository),
        Provider.value(value: playlistRepository),
        Provider.value(value: favoritesRepository),
        Provider.value(value: historyRepository),
        Provider.value(value: userSettingsRepository),
        Provider.value(value: musicProvider),
      ],
      child: const MusicApp(),
    ),
  );
}
