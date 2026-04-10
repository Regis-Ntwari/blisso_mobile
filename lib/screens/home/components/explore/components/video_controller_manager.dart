import 'package:video_player/video_player.dart';

class VideoControllerManager {
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, double> _originalVolumes = {};

  /// Preload a controller for a given index and URL.
  Future<void> preloadController(int index, String url, {bool mute = true}) async {
    if (_controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);
    
    // Store original volume (default is 1.0)
    _originalVolumes[index] = 1.0;
    
    // Mute if requested (for preloaded videos that aren't active)
    if (mute) {
      controller.setVolume(0);
    }
    
    _controllers[index] = controller;
  }

  /// Get the controller for a given index (if it exists).
  VideoPlayerController? getController(int index) => _controllers[index];

  /// Check if controller is initialized
  bool isControllerInitialized(int index) => _controllers.containsKey(index);

  /// Unmute a specific controller
  void unmuteController(int index) {
    final controller = _controllers[index];
    if (controller != null) {
      final volume = _originalVolumes[index] ?? 1.0;
      controller.setVolume(volume);
    }
  }

  /// Mute a specific controller
  void muteController(int index) {
    _controllers[index]?.setVolume(0);
  }

  /// Keep controllers within a range
  void retainInRange({required int minIndex, required int maxIndex, required int currentIndex}) {
    final toRemove = _controllers.keys
        .where((k) => k < minIndex || k > maxIndex)
        .where((k) => k != currentIndex) // Always keep current
        .toList();
        
    for (final key in toRemove) {
      _controllers[key]?.dispose();
      _controllers.remove(key);
      _originalVolumes.remove(key);
    }
  }

  /// Dispose a specific controller
  void disposeController(int index) {
    _controllers[index]?.dispose();
    _controllers.remove(index);
    _originalVolumes.remove(index);
  }

  /// Dispose everything
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _originalVolumes.clear();
  }

  /// Get currently active (loaded) indexes.
  Iterable<int> get activeIndexes => _controllers.keys;
  
  /// Get count of loaded controllers
  int get loadedCount => _controllers.length;
}