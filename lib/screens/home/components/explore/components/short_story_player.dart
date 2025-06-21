import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/stories/like_video_post_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
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

  bool isProfileLoading = false;

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
    ref
        .read(likeVideoPostProviderImpl.notifier)
        .likeVideoPost(int.parse(widget.video.id));
    setState(() {
      if(isLiked) {
        //widget.video.likes = widget.video.likes - 1;
      }
      isLiked = !isLiked;
      
    });
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
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                ),
              )
            : SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    color: Colors.black,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
        // Right side action buttons
        Positioned(
          right: 2,
          bottom: 100,
          child: Column(
            children: [
              // Profile picture
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        setState(() {
                          isProfileLoading = true;
                        });
                        try {
                          final profileRef =
                              ref.read(anyProfileServiceProviderImpl.notifier);
                          await profileRef.getAnyProfile(widget.video.username);

                          final targetProfile =
                              ref.read(targetProfileProvider.notifier);
                          final profileData =
                              ref.read(anyProfileServiceProviderImpl);

                          targetProfile.updateTargetProfile(
                              TargetProfileModel.fromMap(
                                  profileData.data as Map<String, dynamic>));
                          setState(() {
                            isProfileLoading = false;
                          });
                          if (mounted) {
                            Routemaster.of(context)
                                .push('/homepage/target-profile');
                          }
                        } catch (e) {
                          showSnackBar(context, 'Failed to load profile');
                        }
                      },
                      icon: CircleAvatar(
                          radius: 20,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.video.profilePicture,
                          ),
                          onBackgroundImageError: (_, __) {},
                          child: Container()),
                    ),
              // Like button
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: _handleLike,
                      icon: Icon(
                        Icons.favorite,
                        color: widget.video.likedThisStory || isLiked
                            ? GlobalColors.primaryColor
                            : Colors.white,
                        size: 32,
                      ),
                    ),
              // Add likes count below like button
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        width: 40,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Text(
                        '${widget.video.likes}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              const SizedBox(height: 5),
              // Share button
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                      icon: Transform.rotate(
                        angle: 325 *
                            (3.1415926535 / 180), // Convert degrees to radians
                        child: const Icon(
                          color: Colors.white,
                          Icons.send,
                          size: 32,
                        ),
                      )),
              const SizedBox(
                height: 5,
              ),
              _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        // TODO: Caption functionality
                      },
                      icon: InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                          child: Text(
                            'Caption',
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      )),
            ],
          ),
        ),
        isProfileLoading ? const Center(child: CircularProgressIndicator(color: Colors.white, ),) : Container()
      ],
    );
  }
}
