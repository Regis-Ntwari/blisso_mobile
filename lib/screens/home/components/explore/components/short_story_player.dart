import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/share_story_modal.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/stories/get_video_post_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class ShortStoryPlayer extends ConsumerStatefulWidget {
  final ShortStoryModel video;
  final VideoPlayerController? videoController;
  final bool isActive;
  final bool showStory;

  const ShortStoryPlayer(
      {super.key,
      required this.video,
      this.videoController,
      required this.isActive,
      this.showStory = true});

  @override
  ConsumerState<ShortStoryPlayer> createState() => _ShortStoryPlayerState();
}

class _ShortStoryPlayerState extends ConsumerState<ShortStoryPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  bool _isLoading = true;
  bool isProfileLoading = false;
  bool showCaption = false;

  @override
  void initState() {
    super.initState();

    if (widget.videoController != null) {
      _controller = widget.videoController!;
      _isInitialized = _controller.value.isInitialized;
      _isLoading = !_isInitialized;
    } else {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));
      _initializeController();
    }

    _controller.addListener(_handleVideoListener);

    if (widget.isActive) {
      _playIfReady();
    }
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      _controller.setLooping(true);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleVideoListener() {
    if (!mounted) return;

    // Update buffering state
    final isBuffering = _controller.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() => _isBuffering = isBuffering);
    }

    // Show loading if video hasn't started playing yet
    if (!_controller.value.isPlaying &&
        _controller.value.position == Duration.zero &&
        !_isBuffering &&
        _isInitialized) {
      setState(() => _isLoading = true);
    } else if (_controller.value.isPlaying || _isBuffering) {
      setState(() => _isLoading = false);
    }
  }

  void _handleLike() {
    widget.video.likes = widget.video.likedThisStory
        ? widget.video.likes - 1
        : widget.video.likes + 1;
    ref
        .read(getVideoPostProviderImpl.notifier)
        .likeVideoPost(int.parse(widget.video.id));
    setState(() {});
  }

  Future<void> _playIfReady() async {
    if (!_isInitialized) {
      // Wait for initialization before playing
      await _initializeController();
    }

    if (_isInitialized && !_controller.value.isPlaying) {
      await _controller.play();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pauseIfPlaying() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    }
  }

  @override
  void didUpdateWidget(covariant ShortStoryPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? _playIfReady() : _pauseIfPlaying();
    }
  }

  @override
void dispose() {
  _controller.removeListener(_handleVideoListener);

  if (widget.videoController == null) {
    _controller.dispose();
  }

  super.dispose();
}


  Widget _buildLoadingIndicator() {
    return Stack(
      children: [
        // Background shimmer for whole screen
        Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
        ),
        // Centered loading indicator
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: GlobalColors.primaryColor,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBufferingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          color: GlobalColors.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return SizedBox.expand(
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
    );
  }

  Widget _buildShimmerPlaceholder(Widget child) {
    return !_isInitialized && _isLoading
        ? Shimmer.fromColors(
            baseColor: Colors.grey[900]!,
            highlightColor: Colors.grey[800]!,
            child: child,
          )
        : child;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video or Loading Background
        if (!_isInitialized || _isLoading)
          _buildLoadingIndicator()
        else
          _buildVideoPlayer(),

        // Buffering overlay (on top of video)
        if (_isBuffering && _isInitialized) _buildBufferingIndicator(),

        // Right side action buttons
        Positioned(
          right: 2,
          bottom: 100,
          child: Column(
            children: [
              // Profile picture
              if (widget.showStory)
                _buildShimmerPlaceholder(
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[800],
                    child: !_isInitialized
                        ? null
                        : InkWell(
                            onTap: () async {
                              setState(() {
                                isProfileLoading = true;
                              });
                              try {
                                if (ref.read(permissionProviderImpl)[
                                    'can_view_profile_detail']) {
                                  final profileRef = ref.read(
                                      anyProfileServiceProviderImpl.notifier);
                                  await profileRef
                                      .getAnyProfile(widget.video.username);

                                  final targetProfile =
                                      ref.read(targetProfileProvider.notifier);
                                  final profileData =
                                      ref.read(anyProfileServiceProviderImpl);

                                  targetProfile.updateTargetProfile(
                                      TargetProfileModel.fromMap(profileData
                                          .data as Map<String, dynamic>));
                                  setState(() {
                                    isProfileLoading = false;
                                  });
                                  if (mounted) {
                                    Routemaster.of(context)
                                        .push('/homepage/target-profile');
                                  } else {
                                    showPopupComponent(
                                        context: context,
                                        icon: Icons.error,
                                        message: 'Please upgrade your package');
                                  }
                                }
                              } catch (e) {
                                showSnackBar(context, 'Failed to load profile');
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isProfileLoading = false;
                                  });
                                }
                              }
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: CachedNetworkImageProvider(
                                widget.video.profilePicture,
                              ),
                              onBackgroundImageError: (_, __) {},
                            ),
                          ),
                  ),
                ),

              const SizedBox(height: 16),

              // Like button
              _buildShimmerPlaceholder(
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: _isInitialized ? _handleLike : null,
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
                ),
              ),

              // Likes count
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: _buildShimmerPlaceholder(
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.video.likes}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: _isInitialized
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 2,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Share button
              _buildShimmerPlaceholder(
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: _isInitialized
                        ? () {
                            ref.read(permissionProviderImpl)[
                                    'can_share_video_post']
                                ? showShareVideoModal(context, widget.video)
                                : showPopupComponent(
                                    context: context,
                                    icon: Icons.error,
                                    message: 'Please upgrade your plan');
                          }
                        : null,
                    icon: Transform.rotate(
                      angle: 325 * (3.1415926535 / 180),
                      child: Icon(
                        color: Colors.white,
                        Icons.send,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),

              // Shares count
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: _buildShimmerPlaceholder(
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.video.shares}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: _isInitialized
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 2,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Caption button
              _buildShimmerPlaceholder(
                InkWell(
                  onTap: _isInitialized
                      ? () {
                          ref.read(permissionProviderImpl)[
                                  'can_view_video_post_caption']
                              ? showModalBottomSheet(
                                  context: context,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.6),
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
                                                ),
                                              ),
                                            ),
                                            Text(
                                              widget.video.description,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : showPopupComponent(
                                  context: context,
                                  icon: Icons.error,
                                  message: 'Please upgrade your plan');
                        }
                      : null,
                  child: CircleAvatar(
                    backgroundColor: GlobalColors.primaryColor,
                    radius: 20,
                    child: Text(
                      'Caption',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile loading indicator
        if (isProfileLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
