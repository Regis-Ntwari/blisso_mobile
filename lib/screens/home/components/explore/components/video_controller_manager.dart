import 'package:video_player/video_player.dart';

class VideoControllerManager {
  final Map<int, VideoPlayerController> _controllers = {};

  Future<void> preloadController(int index, String url) async {
    if (_controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);
    _controllers[index] = controller;
  }

  VideoPlayerController? getController(int index) {
    return _controllers[index];
  }

  void disposeController(int index) {
    _controllers[index]?.dispose();
    _controllers.remove(index);
  }

  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  List<int> get activeIndexes => _controllers.keys.toList();
}
