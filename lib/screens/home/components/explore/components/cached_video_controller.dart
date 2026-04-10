import 'dart:io';
import 'package:blisso_mobile/screens/home/components/explore/components/video_cache_manager.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createCachedVideoController(
  String url,
) async {
  final File file = await VideoCacheManager().getSingleFile(url);

  final controller = VideoPlayerController.file(file);
  await controller.initialize();
  controller.setLooping(true);

  return controller;
}
