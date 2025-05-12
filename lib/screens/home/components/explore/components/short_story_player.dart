import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShortStoryPlayer extends ConsumerStatefulWidget {
  final ShortStoryModel video;
  const ShortStoryPlayer({super.key, required this.video});

  @override
  ConsumerState<ShortStoryPlayer> createState() => _ShortStoryPlayerState();
}

class _ShortStoryPlayerState extends ConsumerState<ShortStoryPlayer> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  late ChewieController _chewieController;
  bool isLiked = false;

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

  void _handleLike() {
    // ref
    //     .read(storiesServiceProviderImpl.notifier)
    //     .likeStory(int.parse(widget.video.id));
    // setState(() {
    //   isLiked = !isLiked;
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final shimmerBaseColor =
        isLightTheme ? Colors.grey[300]! : Colors.grey[800]!;
    final shimmerHighlightColor =
        isLightTheme ? Colors.grey[100]! : Colors.grey[700]!;

    return Stack(
      children: [
        _isLoading
            ? Shimmer.fromColors(
                baseColor: shimmerBaseColor,
                highlightColor: shimmerHighlightColor,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: isLightTheme ? Colors.grey[200] : Colors.black,
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
        // Username and description
        Positioned(
          bottom: 80,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: shimmerBaseColor,
                      highlightColor: shimmerHighlightColor,
                      child: Container(
                        width: 120,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isLightTheme
                              ? Colors.grey[200]
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  : Text(
                      widget.video.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(height: 4),
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: shimmerBaseColor,
                      highlightColor: shimmerHighlightColor,
                      child: Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isLightTheme
                              ? Colors.grey[200]
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  : Text(
                      widget.video.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
            ],
          ),
        ),
        // Right side action buttons
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // Like button
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: shimmerBaseColor,
                      highlightColor: shimmerHighlightColor,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isLightTheme
                              ? Colors.grey[200]
                              : Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: _handleLike,
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 32,
                      ),
                    ),
              const SizedBox(height: 16),
              // Share button
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: shimmerBaseColor,
                      highlightColor: shimmerHighlightColor,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isLightTheme
                              ? Colors.grey[200]
                              : Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
