import 'package:video_player/video_player.dart';

class FeedVideoControllerManager {
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _initializing = {};

  static const int maxControllers = 6;

  VideoPlayerController? get(int index) => _controllers[index];

  bool has(int index) => _controllers.containsKey(index);

  /// PRELOAD ONLY — never awaited from UI
  void preload(int index, String url, {bool muted = true}) {
    if (_controllers.containsKey(index) || _initializing[index] == true) return;

    _initializing[index] = true;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    controller.initialize().then((_) {
      controller.setLooping(true);
      if (muted) controller.setVolume(0);

      _controllers[index] = controller;
      _initializing.remove(index);

      _evictIfNeeded();
    }).catchError((_) {
      _initializing.remove(index);
    });
  }

  void play(int index) {
    final controller = _controllers[index];
    if (controller == null || !controller.value.isInitialized) return;

    controller.setVolume(1);
    controller.play();
  }

  void pauseAllExcept(int active) {
    for (final entry in _controllers.entries) {
      if (entry.key != active) {
        entry.value.pause();
        entry.value.setVolume(0);
      }
    }
  }

  void retainRange(int min, int max) {
    final keys = _controllers.keys.toList();
    for (final key in keys) {
      if (key < min || key > max) {
        _controllers[key]?.dispose();
        _controllers.remove(key);
      }
    }
  }

  void _evictIfNeeded() {
    if (_controllers.length <= maxControllers) return;

    final keys = _controllers.keys.toList()..sort();
    final excess = _controllers.length - maxControllers;

    for (int i = 0; i < excess; i++) {
      _controllers[keys[i]]?.dispose();
      _controllers.remove(keys[i]);
    }
  }

  void disposeAll() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _initializing.clear();
  }
}
