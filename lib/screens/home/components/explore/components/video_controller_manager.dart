import 'package:video_player/video_player.dart';

class VideoControllerManager {
  final Map<int, VideoPlayerController> _controllers = {};

  /// Preload a controller for a given index and URL.
  /// If already initialized, does nothing.
  Future<void> preloadController(int index, String url) async {
    if (_controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(0); // Mute preload for smoother transitions
    _controllers[index] = controller;
  }

  /// Get the controller for a given index (if it exists).
  VideoPlayerController? getController(int index) => _controllers[index];

  /// Keep only current, previous, and next controllers.
  /// Disposes others to save memory.
  void retainAround(int currentIndex) {
    final keysToKeep = {currentIndex - 1, currentIndex, currentIndex + 1};
    final toRemove = _controllers.keys.where((k) => !keysToKeep.contains(k)).toList();
    for (final key in toRemove) {
      _controllers[key]?.dispose();
      _controllers.remove(key);
    }
  }

  /// Dispose a specific controller (e.g., when far off-screen)
  void disposeController(int index) {
    _controllers[index]?.dispose();
    _controllers.remove(index);
  }

  /// Dispose everything (e.g., on widget dispose)
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  /// Get currently active (loaded) indexes.
  Iterable<int> get activeIndexes => _controllers.keys;
}
