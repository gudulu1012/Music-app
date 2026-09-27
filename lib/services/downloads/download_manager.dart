import 'package:flutter/foundation.dart';
import '../../models/song.dart';

/// State of an individual download.
enum DownloadStatus { queued, downloading, completed, failed, cancelled }

/// Represents the state of a single download task.
class DownloadTask {
  final String songId;
  final String songTitle;
  final String url;
  final DownloadStatus status;
  final double progress; // 0.0 – 1.0
  final String? localFilePath;
  final String? errorMessage;

  const DownloadTask({
    required this.songId,
    required this.songTitle,
    required this.url,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.localFilePath,
    this.errorMessage,
  });

  DownloadTask copyWith({
    DownloadStatus? status,
    double? progress,
    String? localFilePath,
    String? errorMessage,
  }) {
    return DownloadTask(
      songId: songId,
      songTitle: songTitle,
      url: url,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localFilePath: localFilePath ?? this.localFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Download manager for offline audio.
///
/// Manages download queue, progress tracking, cancellation, and
/// local file management. The actual downloaded audio stays on the
/// device — only metadata goes to Firestore.
///
/// For Phase 1, this is a state-only stub.
class DownloadManager extends ChangeNotifier {
  final Map<String, DownloadTask> _downloads = {};

  // ─── Getters ────────────────────────────────────────────────

  /// All current download tasks.
  Map<String, DownloadTask> get downloads => Map.unmodifiable(_downloads);

  /// Get the download task for a specific song.
  DownloadTask? getDownloadTask(String songId) => _downloads[songId];

  /// Check if a song is downloaded.
  bool isDownloaded(String songId) =>
      _downloads[songId]?.status == DownloadStatus.completed;

  /// Check if a song is currently downloading.
  bool isDownloading(String songId) =>
      _downloads[songId]?.status == DownloadStatus.downloading;

  /// Get all completed downloads.
  List<DownloadTask> get completedDownloads =>
      _downloads.values
          .where((t) => t.status == DownloadStatus.completed)
          .toList();

  /// Get all active (downloading or queued) downloads.
  List<DownloadTask> get activeDownloads =>
      _downloads.values
          .where(
            (t) =>
                t.status == DownloadStatus.downloading ||
                t.status == DownloadStatus.queued,
          )
          .toList();

  // ─── Download Operations ────────────────────────────────────

  /// Start downloading a song.
  Future<void> downloadSong(Song song) async {
    if (_downloads.containsKey(song.id)) return;

    _downloads[song.id] = DownloadTask(
      songId: song.id,
      songTitle: song.title,
      url: song.streamUrl,
      status: DownloadStatus.downloading,
    );
    notifyListeners();

    // TODO: Implement actual download using http or dio
    // Simulate download progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _downloads[song.id] = _downloads[song.id]!.copyWith(
        progress: i / 10,
      );
      notifyListeners();
    }

    _downloads[song.id] = _downloads[song.id]!.copyWith(
      status: DownloadStatus.completed,
      progress: 1.0,
      localFilePath: '/downloads/${song.id}.mp3', // Placeholder path
    );
    notifyListeners();
  }

  /// Cancel an active download.
  void cancelDownload(String songId) {
    final task = _downloads[songId];
    if (task != null &&
        (task.status == DownloadStatus.downloading ||
            task.status == DownloadStatus.queued)) {
      _downloads[songId] = task.copyWith(status: DownloadStatus.cancelled);
      notifyListeners();
    }
  }

  /// Delete a downloaded file.
  Future<void> deleteDownload(String songId) async {
    // TODO: Delete the actual file from device storage
    _downloads.remove(songId);
    notifyListeners();
  }

  /// Retry a failed download.
  Future<void> retryDownload(Song song) async {
    _downloads.remove(song.id);
    await downloadSong(song);
  }

  /// Get the local file path for a downloaded song.
  String? getLocalPath(String songId) => _downloads[songId]?.localFilePath;

  /// Delete all downloaded files.
  Future<void> deleteAllDownloads() async {
    // TODO: Delete all local files
    _downloads.clear();
    notifyListeners();
  }
}
