import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedVideoControllerManager {
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _initializing = {};

  // Keep more controllers alive — enough for smooth scrolling both ways
  static const int _maxControllers = 9;

  VideoPlayerController? get(int index) => _controllers[index];

  bool has(int index) => _controllers.containsKey(index);

  /// Preload a video at [index]. Safe to call repeatedly — no-ops if already
  /// initialised or currently initialising.
  void preload(int index, String url, {bool muted = true}) {
    if (_controllers.containsKey(index) || _initializing[index] == true) return;
    if (url.isEmpty) return;

    _initializing[index] = true;

    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(
        // Allows audio from multiple controllers simultaneously so we can
        // preload neighbours without them accidentally making sound.
        mixWithOthers: true,
      ),
    );

    ctrl.initialize().then((_) {
      ctrl.setLooping(true);
      ctrl.setVolume(muted ? 0 : 1);
      _controllers[index] = ctrl;
      _initializing.remove(index);
      _evictIfNeeded();
    }).catchError((_) {
      _initializing.remove(index);
      ctrl.dispose();
    });
  }

  /// Play the controller at [index]. If not yet initialised, attach a one-shot
  /// listener that plays as soon as initialisation completes.
  void play(int index) {
    final ctrl = _controllers[index];
    if (ctrl == null) return;

    ctrl.setVolume(1);

    if (ctrl.value.isInitialized) {
      ctrl.play();
    } else {
      // Rare: controller exists but init not done yet — play on first update.
      late VoidCallback listener;
      listener = () {
        if (ctrl.value.isInitialized && !ctrl.value.isPlaying) {
          ctrl.play();
          ctrl.removeListener(listener);
        }
      };
      ctrl.addListener(listener);
    }
  }

  void pause(int index) {
    _controllers[index]?.pause();
    _controllers[index]?.setVolume(0);
  }

  void pauseAllExcept(int active) {
    for (final entry in _controllers.entries) {
      if (entry.key != active) {
        entry.value.pause();
        entry.value.setVolume(0);
      }
    }
  }

  /// Dispose controllers outside [min]..[max] (inclusive).
  void retainRange(int min, int max) {
    for (final key in _controllers.keys.toList()) {
      if (key < min || key > max) {
        _controllers[key]?.dispose();
        _controllers.remove(key);
      }
    }
  }

  void _evictIfNeeded() {
    if (_controllers.length <= _maxControllers) return;
    // Evict the lowest indices (furthest behind the current position)
    final sorted = _controllers.keys.toList()..sort();
    final excess = _controllers.length - _maxControllers;
    for (int i = 0; i < excess; i++) {
      _controllers[sorted[i]]?.dispose();
      _controllers.remove(sorted[i]);
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