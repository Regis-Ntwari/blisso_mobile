import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String? videoUrl;
  final String? bytes;
  const VideoPlayerScreen({super.key, this.videoUrl, this.bytes});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    if (widget.bytes != null && widget.bytes != '') {
      _initializeVideoFromBytes(
          base64Decode(Uri.decodeComponent(widget.bytes!)));
    } else if (widget.videoUrl != null && widget.videoUrl != '') {
      _initializeVideoFromUrl(Uri.decodeComponent(widget.videoUrl!));
    }
  }

  Future<void> _initializeVideoFromBytes(Uint8List videoBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempVideoFile = File('${tempDir.path}/temp_video.mp4');
      await tempVideoFile.writeAsBytes(videoBytes);

      _videoPlayerController = VideoPlayerController.file(tempVideoFile);
      _videoPlayerController!
          .initialize()
          .then((_) => _createChewieController());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _initializeVideoFromUrl(String videoUrl) {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoPlayerController!.initialize().then((_) => _createChewieController());
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Routemaster.of(context).pop();
            },
            icon: const Icon(Icons.keyboard_arrow_left),
            color: Colors.white,
          ),
          title: const Text(
            'Video',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: _videoPlayerController == null ||
                !_videoPlayerController!.value.isInitialized ||
                _chewieController == null
            ? const Center(
                child: CircularProgressIndicator(
                color: GlobalColors.primaryColor,
              ))
            : Center(
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: Chewie(
                    controller: _chewieController!,
                  ),
                ),
              ));
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
