// import 'package:better_player/better_player.dart';
// import 'package:flutter/material.dart';

// class BetterVideoControllerManager {
//   final Map<int, BetterPlayerController> _controllers = {};

//   static const int maxControllers = 6;

//   BetterPlayerController? getController(int index) => _controllers[index];

//   bool hasController(int index) => _controllers.containsKey(index);

//   Future<void> preload({
//   required int index,
//   required String url,
//   bool autoPlay = false,
//   bool mute = true,
// }) async {
//   if (_controllers.containsKey(index)) return;

//   late BetterPlayerController controller;

//   final dataSource = BetterPlayerDataSource(
//     BetterPlayerDataSourceType.network,
//     url,
//     cacheConfiguration: const BetterPlayerCacheConfiguration(
//       useCache: true,
//       maxCacheSize: 300 * 1024 * 1024, // 300MB
//       maxCacheFileSize: 50 * 1024 * 1024, // 50MB per video
//     ),
//     bufferingConfiguration: const BetterPlayerBufferingConfiguration(
//       minBufferMs: 1500,
//       maxBufferMs: 5000,
//       bufferForPlaybackMs: 500,
//       bufferForPlaybackAfterRebufferMs: 1000,
//     ),
//   );

//   controller = BetterPlayerController(
//     BetterPlayerConfiguration(
//       autoPlay: autoPlay,
//       looping: true,
//       fit: BoxFit.cover,
//       handleLifecycle: true,
//       autoDispose: false,
//       controlsConfiguration: const BetterPlayerControlsConfiguration(
//         showControls: false,
//       ),
//       eventListener: (event) {
//         if (event.betterPlayerEventType ==
//                 BetterPlayerEventType.initialized &&
//             autoPlay) {
//           controller.play(); // ✅ now valid
//         }
//       },
//     ),
//     betterPlayerDataSource: dataSource,
//   );

//   if (mute) {
//     controller.setVolume(0);
//   }

//   _controllers[index] = controller;
//   _evictIfNeeded();
// }


//   void play(int index) {
//     final controller = _controllers[index];
//     if (controller == null) return;

//     controller.setVolume(1);
//     controller.play();
//   }

//   void pause(int index) {
//     _controllers[index]?.pause();
//   }

//   void stopOthers(int activeIndex) {
//     for (final entry in _controllers.entries) {
//       if (entry.key != activeIndex) {
//         entry.value.pause();
//         entry.value.setVolume(0);
//       }
//     }
//   }

//   void retainRange({
//     required int min,
//     required int max,
//     required int current,
//   }) {
//     final keysToRemove = _controllers.keys
//         .where((k) => k < min || k > max)
//         .where((k) => k != current)
//         .toList();

//     for (final key in keysToRemove) {
//       _controllers[key]?.dispose();
//       _controllers.remove(key);
//     }
//   }

//   void _evictIfNeeded() {
//     if (_controllers.length <= maxControllers) return;

//     final excess = _controllers.length - maxControllers;
//     final keys = _controllers.keys.toList()..sort();

//     for (int i = 0; i < excess; i++) {
//       _controllers[keys[i]]?.dispose();
//       _controllers.remove(keys[i]);
//     }
//   }

//   void disposeAll() {
//     for (final controller in _controllers.values) {
//       controller.dispose();
//     }
//     _controllers.clear();
//   }
// }
