import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayer extends StatefulWidget {
  final dynamic message;

  const VideoPlayer({super.key, required this.message});

  @override
  State<VideoPlayer> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayer> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.message['content_file_url'] !=
            oldWidget.message['content_file_url'] ||
        widget.message['content_file'] != oldWidget.message['content_file']) {
      _disposeControllers();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.message['content_file_url'] != null &&
          widget.message['content_file_url'].toString().startsWith('https')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.message['content_file_url']),
        );
      } else if (widget.message['content_file'] != null) {
        // Decode and save video bytes as a temporary file
        debugPrint("In else if");
        String tempPath =
            '${(await Directory.systemTemp.createTemp()).path}/temp_video.mp4';
        File tempFile = File(tempPath);
        await tempFile
            .writeAsBytes(base64Decode(widget.message['content_file']!));
        _controller = VideoPlayerController.file(tempFile);
      } else {
        debugPrint("In Else");
        return; // No valid video source
      }

      await _controller!.initialize();

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _controller!,
          autoPlay: false,
          looping: false,
          showControls: false,
        );
      });
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  void _disposeControllers() {
    // _controller?.dispose();
    // _chewieController?.dispose();
  }

  @override
  void dispose() {
    // _disposeControllers();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _controller!,
            autoPlay: false,
            looping: false,
            showControls: true,
          );
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ],
      ),
    );
  }
}
