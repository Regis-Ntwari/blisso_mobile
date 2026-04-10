import 'dart:io';

import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoTrimmerScreen extends StatefulWidget {
  final File videoFile;
  final String title;

  const VideoTrimmerScreen({
    super.key,
    required this.videoFile,
    this.title = 'Trim Video',
  });

  @override
  State<VideoTrimmerScreen> createState() => _VideoTrimmerScreenState();
}

class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isTrimming = false;

  double _startValue = 0.0;
  double _endValue = 1.0;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    await _controller!.initialize();
    _totalDuration = _controller!.value.duration;
    _controller!.addListener(_onVideoProgress);
    setState(() {
      _isInitialized = true;
    });
  }

  void _onVideoProgress() {
    if (!mounted || _controller == null) return;
    final position = _controller!.value.position;
    final endPosition = Duration(
        milliseconds: (_endValue * _totalDuration.inMilliseconds).round());
    if (position >= endPosition) {
      _controller!.pause();
      _controller!.seekTo(Duration(
          milliseconds: (_startValue * _totalDuration.inMilliseconds).round()));
    }
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Duration get _startDuration => Duration(
      milliseconds: (_startValue * _totalDuration.inMilliseconds).round());

  Duration get _endDuration => Duration(
      milliseconds: (_endValue * _totalDuration.inMilliseconds).round());

  Duration get _selectedDuration => _endDuration - _startDuration;

  Future<void> _trimAndReturn() async {
    setState(() => _isTrimming = true);

    try {
      final startSeconds = _startDuration.inSeconds;
      final durationSeconds = _selectedDuration.inSeconds;

      if (durationSeconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid video section'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isTrimming = false);
        return;
      }

      final result = await VideoCompress.compressVideo(
        widget.videoFile.path,
        quality: VideoQuality.DefaultQuality,
        startTime: startSeconds,
        duration: durationSeconds,
        includeAudio: true,
      );

      if (result != null && result.file != null) {
        if (mounted) {
          Navigator.of(context).pop(result.file!);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to trim video. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error trimming video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error trimming video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTrimming = false);
    }
  }

  void _playPreview() {
    if (_controller == null) return;
    _controller!.seekTo(_startDuration);
    _controller!.play();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    VideoCompress.cancelCompression();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (!_isTrimming)
            TextButton(
              onPressed: () {
                // Skip trimming - return original file
                Navigator.of(context).pop(widget.videoFile);
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(
                color: GlobalColors.primaryColor,
              ),
            )
          : Column(
              children: [
                // Video preview
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),

                // Play/Pause button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: IconButton(
                    onPressed: () {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                      } else {
                        _playPreview();
                      }
                      setState(() {});
                    },
                    icon: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),

                // Time labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_startDuration),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        'Selected: ${_formatDuration(_selectedDuration)}',
                        style: const TextStyle(
                          color: GlobalColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDuration(_endDuration),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Range slider for trimming
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: GlobalColors.primaryColor,
                      inactiveTrackColor: Colors.grey[700],
                      thumbColor: GlobalColors.primaryColor,
                      overlayColor:
                          GlobalColors.primaryColor.withValues(alpha: 0.2),
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                      rangeTrackShape:
                          const RoundedRectRangeSliderTrackShape(),
                    ),
                    child: RangeSlider(
                      values: RangeValues(_startValue, _endValue),
                      onChanged: (values) {
                        setState(() {
                          _startValue = values.start;
                          _endValue = values.end;
                        });
                      },
                      onChangeEnd: (values) {
                        _controller!.seekTo(Duration(
                            milliseconds: (values.start *
                                    _totalDuration.inMilliseconds)
                                .round()));
                      },
                    ),
                  ),
                ),

                // Total duration label
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Total: ${_formatDuration(_totalDuration)}',
                    style:
                        TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),

                // Trim button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isTrimming ? null : _trimAndReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isTrimming
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Trimming...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Trim & Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
