import 'package:flutter/foundation.dart';
import '../../models/song.dart';

/// Playback states exposed to the UI.
enum PlaybackState { idle, loading, playing, paused, error }

/// Repeat modes.
enum RepeatMode { off, all, one }

/// Central audio playback manager.
///
/// This service owns all playback state and is independent of any screen.
/// MiniPlayer, NowPlayingScreen, and QueueScreen all read from this service.
///
/// Architecture notes:
/// - In production, this wraps `just_audio` + `audio_service`.
/// - For Phase 1, it tracks state without actual audio playback.
/// - Call play/pause/seek and the state updates; the UI reacts via
///   ChangeNotifier.
class AudioManager extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────
  PlaybackState _playbackState = PlaybackState.idle;
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = -1;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // ─── Getters ────────────────────────────────────────────────
  PlaybackState get playbackState => _playbackState;
  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get shuffleEnabled => _shuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  bool get isPlaying => _playbackState == PlaybackState.playing;
  bool get hasSong => _currentSong != null;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  /// Progress fraction 0.0 – 1.0.
  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  // ─── Playback Controls ──────────────────────────────────────

  /// Play a single song (replaces the queue).
  Future<void> play(Song song) async {
    _currentSong = song;
    _queue = [song];
    _currentIndex = 0;
    _position = Duration.zero;
    _duration = song.duration;
    _playbackState = PlaybackState.playing;

    // TODO: Initialize just_audio player with song.playbackUrl
    // await _player.setUrl(song.playbackUrl);
    // await _player.play();

    notifyListeners();
  }

  /// Play a list of songs starting at the given index.
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _queue = List.from(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);
    _currentSong = _queue[_currentIndex];
    _position = Duration.zero;
    _duration = _currentSong!.duration;
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }

  /// Pause playback.
  void pause() {
    if (_playbackState == PlaybackState.playing) {
      _playbackState = PlaybackState.paused;
      notifyListeners();
    }
  }

  /// Resume playback.
  void resume() {
    if (_playbackState == PlaybackState.paused) {
      _playbackState = PlaybackState.playing;
      notifyListeners();
    }
  }

  /// Toggle play/pause.
  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  /// Stop playback and clear the current song.
  void stop() {
    _playbackState = PlaybackState.idle;
    _currentSong = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  /// Seek to a position.
  Future<void> seek(Duration position) async {
    _position = position;
    notifyListeners();
  }

  /// Seek by a relative offset.
  Future<void> seekRelative(Duration offset) async {
    final newPosition = _position + offset;
    final clamped = Duration(
      milliseconds:
          newPosition.inMilliseconds.clamp(0, _duration.inMilliseconds),
    );
    await seek(clamped);
  }

  /// Skip to the next track in the queue.
  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_repeatMode == RepeatMode.one) {
      _position = Duration.zero;
      notifyListeners();
      return;
    }

    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = 0;
    } else {
      stop();
      return;
    }

    _currentSong = _queue[_currentIndex];
    _position = Duration.zero;
    _duration = _currentSong!.duration;
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }

  /// Skip to the previous track in the queue.
  Future<void> previous() async {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart the current track
    if (_position.inSeconds > 3) {
      _position = Duration.zero;
      notifyListeners();
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = _queue.length - 1;
    } else {
      _position = Duration.zero;
      notifyListeners();
      return;
    }

    _currentSong = _queue[_currentIndex];
    _position = Duration.zero;
    _duration = _currentSong!.duration;
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }

  /// Play a specific song from the queue by index.
  Future<void> skipToIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    _currentSong = _queue[_currentIndex];
    _position = Duration.zero;
    _duration = _currentSong!.duration;
    _playbackState = PlaybackState.playing;
    notifyListeners();
  }

  // ─── Queue Management ───────────────────────────────────────

  /// Add a song to the end of the queue.
  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
  }

  /// Insert a song as the next track.
  void playNext(Song song) {
    final insertAt = _currentIndex + 1;
    _queue.insert(insertAt.clamp(0, _queue.length), song);
    notifyListeners();
  }

  /// Remove a song from the queue by index.
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);

    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex) {
      if (_queue.isEmpty) {
        stop();
      } else {
        _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
        _currentSong = _queue[_currentIndex];
        _duration = _currentSong!.duration;
        _position = Duration.zero;
      }
    }
    notifyListeners();
  }

  /// Reorder a song in the queue.
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    // Adjust current index
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    notifyListeners();
  }

  /// Clear the queue (stops playback).
  void clearQueue() {
    _queue.clear();
    stop();
  }

  // ─── Playback Settings ─────────────────────────────────────

  /// Toggle shuffle mode.
  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    if (_shuffleEnabled && _queue.length > 1) {
      final current = _currentSong;
      _queue.shuffle();
      if (current != null) {
        _queue.remove(current);
        _queue.insert(0, current);
        _currentIndex = 0;
      }
    }
    notifyListeners();
  }

  /// Cycle through repeat modes: off → all → one → off.
  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  /// Set the playback volume (0.0 – 1.0).
  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  // ─── Cleanup ────────────────────────────────────────────────

  @override
  void dispose() {
    // _player.dispose();
    super.dispose();
  }
}
