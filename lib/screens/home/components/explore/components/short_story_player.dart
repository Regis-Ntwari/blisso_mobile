import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';

class ShortStoryPlayer extends StatefulWidget {
  final ShortStoryModel video;
  const ShortStoryPlayer({super.key, required this.video});

  @override
  State<ShortStoryPlayer> createState() => _ShortStoryPlayerState();
}

class _ShortStoryPlayerState extends State<ShortStoryPlayer> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
          ..initialize().then((_) {
            setState(() => _isLoading = false);
          })
          ..setLooping(true)
          ..play();

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      showControls: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _isLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                ),
              )
            : SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
        Positioned(
          bottom: 80,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.video.username,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(widget.video.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
