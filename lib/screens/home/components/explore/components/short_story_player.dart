import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/share_story_modal.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/stories/get_video_post_provider.dart';
import 'package:blisso_mobile/services/stories/paginated_video_post_provider.dart';
import 'package:blisso_mobile/services/video-post/view_video_service_provider.dart';
import 'package:blisso_mobile/services/video-post/video_post_service.dart';
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
  final Function(DateTime startTimestamp, DateTime endTimestamp)? onTimeTrack;

  const ShortStoryPlayer({
    super.key,
    required this.video,
    this.videoController,
    required this.isActive,
    this.showStory = true,
    this.onTimeTrack,
  });

  @override
  ConsumerState<ShortStoryPlayer> createState() => _ShortStoryPlayerState();
}

class _ShortStoryPlayerState extends ConsumerState<ShortStoryPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _buffering = false;

  // ── Pause / play overlay ──────────────────────────────────────────────────
  bool _manuallyPaused = false;
  bool _showPauseIcon = false;
  late AnimationController _iconAnimController;
  late Animation<double> _iconOpacity;

  // ── Seek bar ──────────────────────────────────────────────────────────────
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isSeeking = false;
  double _seekValue = 0;

  // Time tracking
  DateTime? _trackStart;
  bool _tracking = false;

  bool _hasRecordedView = false;
  bool _profileLoading = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.easeOut),
    );

    _attachController(widget.videoController);
  }

  @override
  void didUpdateWidget(covariant ShortStoryPlayer old) {
    super.didUpdateWidget(old);

    if (widget.videoController != old.videoController) {
      _detachController();
      _attachController(widget.videoController);
    }

    if (widget.isActive != old.isActive) {
      if (widget.isActive) {
        if (!_manuallyPaused) _play();
      } else {
        _pause();
        _stopTracking();
      }
    }
  }

  @override
  void deactivate() {
    _pause();
    _stopTracking();
    super.deactivate();
  }

  @override
  void dispose() {
    _stopTracking();
    _detachController();
    _iconAnimController.dispose();
    super.dispose();
  }

  // ── Controller management ─────────────────────────────────────────────────

  void _attachController(VideoPlayerController? ctrl) {
    if (ctrl == null) {
      final url = widget.video.videoUrl;
      if (url.isEmpty) return;
      final owned = VideoPlayerController.networkUrl(Uri.parse(url));
      _ctrl = owned;
      owned.initialize().then((_) {
        if (!mounted) return;
        owned.setLooping(true);
        setState(() {
          _initialized = true;
          _duration = owned.value.duration;
        });
        if (widget.isActive && !_manuallyPaused) _play();
      }).catchError((_) {});
    } else {
      _ctrl = ctrl;
      _initialized = ctrl.value.isInitialized;
      if (_initialized) _duration = ctrl.value.duration;
    }

    _ctrl?.addListener(_onControllerUpdate);
    if (widget.isActive && _initialized && !_manuallyPaused) _play();
  }

  void _detachController() {
    _ctrl?.removeListener(_onControllerUpdate);
    _ctrl?.pause();
    _ctrl?.setVolume(0);
    if (widget.videoController == null) {
      _ctrl?.dispose();
    }
    _ctrl = null;
    _initialized = false;
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  void _play() {
    if (_ctrl == null || !mounted) return;
    _ctrl!.setVolume(1);
    if (_ctrl!.value.isInitialized) {
      _ctrl!.play();
    }
  }

  void _pause() {
    _ctrl?.pause();
    _ctrl?.setVolume(0);
  }

  /// Tap-to-toggle pause/play — user-driven.
  void _togglePlayPause() {
    if (!_initialized || _ctrl == null) return;
    setState(() {
      if (_ctrl!.value.isPlaying) {
        _manuallyPaused = true;
        _pause();
        _stopTracking();
        _showPauseIcon = true;
        _iconAnimController.reset();
        // Keep the icon visible while paused — don't auto-fade.
      } else {
        _manuallyPaused = false;
        _play();
        _showPauseIcon = true;
        _iconAnimController.reset();
        // Fade out the play icon after a short delay.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _iconAnimController.forward();
        });
      }
    });
  }

  // ── Controller listener ───────────────────────────────────────────────────

  void _onControllerUpdate() {
    if (!mounted || _ctrl == null) return;
    final val = _ctrl!.value;

    if (val.isInitialized && !_initialized) {
      setState(() {
        _initialized = true;
        _duration = val.duration;
      });
      if (widget.isActive && !_manuallyPaused) _play();
    }

    if (val.isBuffering != _buffering) {
      setState(() => _buffering = val.isBuffering);
    }

    // Update seek bar position while not dragging.
    if (!_isSeeking && val.isInitialized) {
      setState(() {
        _position = val.position;
        if (val.duration > Duration.zero) {
          _seekValue = val.position.inMilliseconds / val.duration.inMilliseconds;
          _seekValue = _seekValue.clamp(0.0, 1.0);
        }
      });
    }

    if (val.isPlaying && !_tracking) {
      _startTracking();
    }
  }

  // ── Time tracking ─────────────────────────────────────────────────────────

  void _startTracking() {
    if (_tracking || !mounted) return;
    _trackStart = DateTime.now();
    _tracking = true;

    if (!_hasRecordedView) {
      _hasRecordedView = true;
      try {
        ref
            .read(viewVideoServiceProviderImpl.notifier)
            .viewVideo(widget.video.id);
      } catch (_) {}
    }
  }

  void _stopTracking() {
    if (!_tracking || _trackStart == null) return;
    final end = DateTime.now();
    final start = _trackStart!;
    final videoId = widget.video.id;
    _tracking = false;
    _trackStart = null;
    VideoPostService().updateWatchTime(start, end, videoId);
  }

  // ── Like ──────────────────────────────────────────────────────────────────

  void _handleLike() {
    if (!mounted) return;
    setState(() {
      if (widget.video.likedThisStory) {
        widget.video.likes -= 1;
        widget.video.likedThisStory = false;
      } else {
        widget.video.likes += 1;
        widget.video.likedThisStory = true;
      }
    });
    ref.read(paginatedVideoPostProvider.notifier).toggleVideoLike(
          widget.video.id,
          liked: widget.video.likedThisStory,
          likes: widget.video.likes,
        );
    ref
        .read(getVideoPostProviderImpl.notifier)
        .likeVideoPost(int.parse(widget.video.id));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _compact(int v) {
    if (v < 1000) return v.toString();
    String fmt(num n, String s) {
      final f = n.toStringAsFixed(1);
      return '${f.endsWith('.0') ? f.substring(0, f.length - 2) : f}$s';
    }
    if (v < 1000000) return fmt(v / 1000, 'k');
    if (v < 1000000000) return fmt(v / 1000000, 'M');
    return fmt(v / 1000000000, 'B');
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _shimmer(Widget child) {
    if (_initialized) return child;
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: child,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    double size = 28,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: color,
        size: size,
        shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
      ),
    );
  }

  Widget _statLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        shadows: [Shadow(blurRadius: 3, color: Colors.black87)],
      ),
    );
  }

  Widget _buildActionColumn() {
    const double iconSize = 28;
    const double gap = 6;
    const double sectionGap = 20;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showStory)
          _shimmer(
            GestureDetector(
              onTap: _initialized ? _openProfile : null,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[800],
                child: _initialized
                    ? CircleAvatar(
                        radius: 21,
                        backgroundImage: CachedNetworkImageProvider(
                            widget.video.profilePicture),
                        onBackgroundImageError: (_, __) {},
                      )
                    : null,
              ),
            ),
          ),
        if (widget.showStory) const SizedBox(height: sectionGap),

        _shimmer(Icon(
          Icons.remove_red_eye_outlined,
          color: Colors.white,
          size: iconSize,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
        )),
        const SizedBox(height: gap),
        _shimmer(_statLabel(_compact(widget.video.views))),

        const SizedBox(height: sectionGap),

        _shimmer(_actionButton(
          icon: widget.video.likedThisStory
              ? Icons.favorite
              : Icons.favorite_outline,
          color: widget.video.likedThisStory
              ? GlobalColors.primaryColor
              : Colors.white,
          onTap: _initialized ? _handleLike : null,
          size: iconSize,
        )),
        const SizedBox(height: gap),
        _shimmer(_statLabel(_compact(widget.video.likes))),

        const SizedBox(height: sectionGap),

        _shimmer(_actionButton(
          icon: Icons.reply,
          color: Colors.white,
          onTap: _initialized ? _onShare : null,
          size: iconSize,
        )),
        const SizedBox(height: gap),
        _shimmer(_statLabel(_compact(widget.video.shares))),

        const SizedBox(height: sectionGap),

        _shimmer(
          GestureDetector(
            onTap: _initialized ? _onCaption : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GlobalColors.primaryColor,
              ),
              child: const Center(
                child: Text(
                  'CC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Instagram-style seek bar pinned to the bottom of the screen.
  Widget _buildSeekBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_isSeeking
                    ? Duration(
                        milliseconds:
                            (_seekValue * _duration.inMilliseconds).round())
                    : _position),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
          ),
          child: Slider(
            value: _seekValue,
            min: 0,
            max: 1,
            onChangeStart: (_) {
              setState(() => _isSeeking = true);
            },
            onChanged: (v) {
              setState(() => _seekValue = v);
            },
            onChangeEnd: (v) async {
              if (_ctrl != null && _duration > Duration.zero) {
                final target = Duration(
                    milliseconds: (v * _duration.inMilliseconds).round());
                await _ctrl!.seekTo(target);
              }
              setState(() => _isSeeking = false);
              // Resume if it was playing before the seek.
              if (!_manuallyPaused && widget.isActive) _play();
            },
          ),
        ),
      ],
    );
  }

  // ── Action handlers ───────────────────────────────────────────────────────

  Future<void> _openProfile() async {
    if (!mounted) return;
    if (!ref.read(permissionProviderImpl)['can_view_profile_detail']) {
      showPopupComponent(
          context: context,
          icon: Icons.error,
          message: 'Please upgrade your plan');
      return;
    }
    setState(() => _profileLoading = true);
    try {
      await ref
          .read(anyProfileServiceProviderImpl.notifier)
          .getAnyProfile(widget.video.username);
      if (!mounted) return;
      final data = ref.read(anyProfileServiceProviderImpl).data;
      ref.read(targetProfileProvider.notifier).updateTargetProfile(
          TargetProfileModel.fromMap(data as Map<String, dynamic>));
      Routemaster.of(context).push('/homepage/target-profile');
    } catch (_) {
      if (mounted) showSnackBar(context, 'Failed to load profile');
    }
    if (mounted) setState(() => _profileLoading = false);
  }

  void _onShare() {
    if (!mounted) return;
    if (ref.read(permissionProviderImpl)['can_share_video_post']) {
      showShareVideoModal(context, widget.video);
    } else {
      showPopupComponent(
          context: context,
          icon: Icons.error,
          message: 'Please upgrade your plan');
    }
  }

  void _onCaption() {
    if (!mounted) return;
    if (!ref.read(permissionProviderImpl)['can_view_video_post_caption']) {
      showPopupComponent(
          context: context,
          icon: Icons.error,
          message: 'Please upgrade your plan');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.92),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.video.description.isEmpty
                    ? 'No caption'
                    : widget.video.description,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      // Tap anywhere on the video to toggle pause/play.
      onTap: _togglePlayPause,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video / thumbnail / shimmer ────────────────────────────────
          Builder(builder: (context) {
            final ctrl = _ctrl;
            if (ctrl != null && _initialized) {
              return SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: ctrl.value.size.width,
                    height: ctrl.value.size.height,
                    child: VideoPlayer(ctrl),
                  ),
                ),
              );
            }
            return CachedNetworkImage(
              imageUrl: widget.video.postThumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[900]!,
                highlightColor: Colors.grey[800]!,
                child: const ColoredBox(color: Colors.black),
              ),
              errorWidget: (_, __, ___) => Shimmer.fromColors(
                baseColor: Colors.grey[900]!,
                highlightColor: Colors.grey[800]!,
                child: const ColoredBox(color: Colors.black),
              ),
            );
          }),

          // ── Tap-to-pause/play icon overlay ─────────────────────────────
          if (_showPauseIcon && _initialized)
            Center(
              child: FadeTransition(
                opacity: _manuallyPaused
                    ? const AlwaysStoppedAnimation(1.0)
                    : _iconOpacity,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _manuallyPaused ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),

          // ── Buffering spinner ──────────────────────────────────────────
          if (_buffering && _initialized)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ),

          // ── Right-side actions ─────────────────────────────────────────
          // Exclude the seek bar area (approx 60 px) from the right column.
          Positioned(
            right: 10,
            bottom: bottomPad + 90 + 60,
            child: _buildActionColumn(),
          ),

          // ── Bottom gradient + seek bar ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              // Prevent seek bar taps from toggling pause/play.
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                    stops: [0, 1],
                  ),
                ),
                padding: EdgeInsets.only(bottom: bottomPad + 8),
                child: _initialized
                    ? _buildSeekBar()
                    : const SizedBox(height: 48),
              ),
            ),
          ),

          // ── Profile loading overlay ────────────────────────────────────
          if (_profileLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}