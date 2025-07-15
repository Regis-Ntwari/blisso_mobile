import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/share_story_modal.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/stories/get_video_post_provider.dart';
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
  final VideoPlayerController? videoController;
  final bool showStory;

  const ShortStoryPlayer({
    super.key,
    required this.video,
    this.videoController,
    this.showStory = true,
  });

  @override
  ConsumerState<ShortStoryPlayer> createState() => _ShortStoryPlayerState();
}

class _ShortStoryPlayerState extends ConsumerState<ShortStoryPlayer> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _isLoading = true;
  bool isProfileLoading = false;
  bool showCaption = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.videoController ??
        VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));

    _controller.initialize().then((_) {
      setState(() => _isLoading = false);
    });

    _controller.setLooping(true);
    _controller.play();

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      showControls: false,
    );
  }

  void _handleLike() {
    widget.video.likes = widget.video.likedThisStory ? widget.video.likes - 1 : widget.video.likes + 1;
    ref
        .read(getVideoPostProviderImpl.notifier)
        .likeVideoPost(int.parse(widget.video.id));
    setState(() {});
  }

  @override
  void dispose() {
    if (widget.videoController == null) {
      _controller.dispose(); // Only dispose if we created it
    }
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
              _isLoading && widget.showStory
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
                  : widget.showStory
                      ? IconButton(
                          onPressed: () async {
                            setState(() {
                              isProfileLoading = true;
                            });
                            try {
                              final profileRef = ref
                                  .read(anyProfileServiceProviderImpl.notifier);
                              await profileRef
                                  .getAnyProfile(widget.video.username);

                              final targetProfile =
                                  ref.read(targetProfileProvider.notifier);
                              final profileData =
                                  ref.read(anyProfileServiceProviderImpl);

                              targetProfile.updateTargetProfile(
                                  TargetProfileModel.fromMap(profileData.data
                                      as Map<String, dynamic>));
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
                        )
                      : const SizedBox.shrink(),
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
                        widget.video.likedThisStory
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: widget.video.likedThisStory
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
                        showShareVideoModal(context, widget.video);
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
                        '${widget.video.shares}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                  : InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.black.withOpacity(0.6),
                            builder: (ctx) {
                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ))),
                                      Text(
                                        widget.video.description,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: true,
                        //   barrierColor: Colors.black.withOpacity(0.8),
                        //   builder: (_) => Dialog(
                        //     backgroundColor: Colors.transparent,
                        //     child: Center(
                        //       child: Container(
                        //         width: width * 0.95,
                        //         height: height * 0.5,
                        //         padding: const EdgeInsets.all(16),
                        //         decoration: BoxDecoration(
                        //           color: Colors.black.withOpacity(0.6),
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         child: Scrollbar(
                        //           thumbVisibility: true,
                        //           child: SingleChildScrollView(
                        //             child: Text(
                        //               widget.video.description,
                        //               style:
                        //                   const TextStyle(color: Colors.white),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // );
                        setState(() {
                          showCaption = !showCaption;
                        });
                      },
                      child: const CircleAvatar(
                        backgroundColor: GlobalColors.primaryColor,
                        child: Text(
                          'Caption',
                          style: TextStyle(fontSize: 9, color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
        ),

        isProfileLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Container()
      ],
    );
  }
}
