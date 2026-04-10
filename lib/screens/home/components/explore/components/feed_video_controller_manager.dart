import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedVideoControllerManager {
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, VideoPlayerController> _initializing = {};

  bool _disposed = false;

  /// Global pause flag — when false, play() is a no-op.
  /// Prevents any controller from playing while the feed is hidden
  /// (tab switch, app background, route pushed on top).
  bool _feedActive = false;

  static const int _maxControllers = 9;

  VideoPlayerController? get(int index) => _controllers[index];
  bool has(int index) => _controllers.containsKey(index);

  // ── Preload ───────────────────────────────────────────────────────────────

  void preload(int index, String url, {bool muted = true}) {
    if (_disposed) return;
    if (_controllers.containsKey(index) || _initializing.containsKey(index)) return;
    if (url.isEmpty) return;

    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _initializing[index] = ctrl;

    ctrl.initialize().then((_) {
      _initializing.remove(index);
      if (_disposed) {
        ctrl.dispose();
        return;
      }
      ctrl.setLooping(true);
      ctrl.setVolume(muted ? 0 : 1);
      _controllers[index] = ctrl;
      _evictIfNeeded();
    }).catchError((_) {
      _initializing.remove(index);
      ctrl.dispose();
    });
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  /// Activate the feed so play() calls are honoured.
  /// Always call this before play() when bringing the feed into view.
  void activate() {
    _feedActive = true;
  }

  /// Deactivate the feed and immediately silence + pause every controller.
  /// play() will be a no-op until activate() is called again.
  void deactivate() {
    _feedActive = false;
    _pauseAllControllers();
  }

  void play(int index) {
    if (_disposed || !_feedActive) return;

    final ctrl = _controllers[index];
    if (ctrl == null) return;

    ctrl.setVolume(1);

    if (ctrl.value.isInitialized) {
      ctrl.play();
    } else {
      // Rare: controller exists but not yet initialised — play on first update.
      late VoidCallback listener;
      listener = () {
        if (_disposed || !_feedActive) {
          ctrl.removeListener(listener);
          return;
        }
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

  /// Legacy alias kept so call-sites that use pauseAll() still compile.
  void pauseAll() => deactivate();

  // ── Retention ─────────────────────────────────────────────────────────────

  void retainRange(int min, int max) {
    for (final key in _controllers.keys.toList()) {
      if (key < min || key > max) {
        _controllers[key]?.dispose();
        _controllers.remove(key);
      }
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _pauseAllControllers() {
    for (final c in _controllers.values) {
      c.pause();
      c.setVolume(0);
    }
  }

  void _evictIfNeeded() {
    if (_controllers.length <= _maxControllers) return;
    final sorted = _controllers.keys.toList()..sort();
    final excess = _controllers.length - _maxControllers;
    for (int i = 0; i < excess; i++) {
      _controllers[sorted[i]]?.dispose();
      _controllers.remove(sorted[i]);
    }
  }

  void disposeAll() {
    _disposed = true;
    _feedActive = false;
    _pauseAllControllers();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    for (final c in _initializing.values) {
      c.dispose();
    }
    _initializing.clear();
  }
}