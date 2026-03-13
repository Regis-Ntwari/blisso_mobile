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

class _ShortStoryPlayerState extends ConsumerState<ShortStoryPlayer> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _buffering = false;

  // Time tracking
  DateTime? _trackStart;
  bool _tracking = false;

  bool _profileLoading = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _attachController(widget.videoController);
  }

  @override
  void didUpdateWidget(covariant ShortStoryPlayer old) {
    super.didUpdateWidget(old);

    // Controller handed from manager changed
    if (widget.videoController != old.videoController) {
      _detachController();
      _attachController(widget.videoController);
    }

    // Active state changed
    if (widget.isActive != old.isActive) {
      widget.isActive ? _play() : _pause();
    }
  }

  @override
  void dispose() {
    _stopTracking();
    _detachController();
    super.dispose();
  }

  // ── Controller management ─────────────────────────────────────────────────

  void _attachController(VideoPlayerController? ctrl) {
    if (ctrl == null) {
      // Manager hasn't preloaded this slot yet — create our own controller.
      final url = widget.video.videoUrl;
      if (url.isEmpty) return;
      final owned = VideoPlayerController.networkUrl(Uri.parse(url));
      _ctrl = owned;
      owned.initialize().then((_) {
        if (!mounted) return;
        owned.setLooping(true);
        if (mounted) setState(() => _initialized = true);
        if (widget.isActive) _play();
      }).catchError((_) {
        // Swallow — bad URL must never crash the player
      });
    } else {
      _ctrl = ctrl;
      // isInitialized may already be true if the manager finished preloading
      _initialized = ctrl.value.isInitialized;
    }

    // Safe — _ctrl is guaranteed non-null here (unless url was empty)
    _ctrl?.addListener(_onControllerUpdate);
    if (widget.isActive && _initialized) _play();
  }

  void _detachController() {
    _ctrl?.removeListener(_onControllerUpdate);
    // Only dispose if we own the controller (no manager controller was passed)
    if (widget.videoController == null) {
      _ctrl?.dispose();
    }
    _ctrl = null;
    _initialized = false;
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  void _play() {
    if (_ctrl == null) return;
    _ctrl!.setVolume(1);
    if (_ctrl!.value.isInitialized) {
      _ctrl!.play();
    }
    // If not yet initialised the manager's play() method handles it via listener
  }

  void _pause() {
    _ctrl?.pause();
    _ctrl?.setVolume(0);
  }

  // ── Controller listener ───────────────────────────────────────────────────

  void _onControllerUpdate() {
    if (!mounted || _ctrl == null) return;

    final val = _ctrl!.value;

    // Sync initialisation state
    if (val.isInitialized && !_initialized) {
      setState(() => _initialized = true);
      if (widget.isActive) _play();
    }

    // Buffering
    if (val.isBuffering != _buffering) {
      setState(() => _buffering = val.isBuffering);
    }

    // Time tracking
    if (val.isPlaying && !_tracking) {
      _startTracking();
    } else if (!val.isPlaying && _tracking) {
      _stopTracking();
    }
  }

  // ── Time tracking ─────────────────────────────────────────────────────────

  void _startTracking() {
    if (_tracking) return;
    _trackStart = DateTime.now();
    _tracking = true;
  }

  void _stopTracking() {
    if (!_tracking || _trackStart == null) return;
    final end = DateTime.now();
    widget.onTimeTrack?.call(_trackStart!, end);
    _tracking = false;
    _trackStart = null;
  }

  // ── Like ──────────────────────────────────────────────────────────────────

  void _handleLike() {
    setState(() {
      if (widget.video.likedThisStory) {
        widget.video.likes -= 1;
        widget.video.likedThisStory = false;
      } else {
        widget.video.likes += 1;
        widget.video.likedThisStory = true;
      }
    });
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

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _shimmer(Widget child) {
    if (_initialized) return child;
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!, // 750 doesn't exist in Flutter's grey swatch
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
      child: Icon(icon, color: color, size: size,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black54)]),
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

  // The right-side action column — all icons use the same 28 px size
  // and are spaced with consistent SizedBox gaps so nothing misaligns.
  Widget _buildActionColumn() {
    const double iconSize = 28;
    const double gap = 6;
    const double sectionGap = 20;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Profile avatar ──────────────────────────────────────────────
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

        // ── Views ───────────────────────────────────────────────────────
        _shimmer(Icon(Icons.remove_red_eye_outlined,
            color: Colors.white, size: iconSize,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black54)])),
        const SizedBox(height: gap),
        _shimmer(_statLabel(_compact(widget.video.views))),

        const SizedBox(height: sectionGap),

        // ── Like ────────────────────────────────────────────────────────
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

        // ── Share ───────────────────────────────────────────────────────
        _shimmer(_actionButton(
          icon: Icons.reply, // cleaner than rotated send for a share action
          color: Colors.white,
          onTap: _initialized ? _onShare : null,
          size: iconSize,
        )),
        const SizedBox(height: gap),
        _shimmer(_statLabel(_compact(widget.video.shares))),

        const SizedBox(height: sectionGap),

        // ── Caption ─────────────────────────────────────────────────────
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

  // ── Action handlers ───────────────────────────────────────────────────────

  Future<void> _openProfile() async {
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
    if (ref.read(permissionProviderImpl)['can_share_video_post']) {
      showShareVideoModal(context, widget.video);
    } else {
      showPopupComponent(
          context: context, icon: Icons.error, message: 'Please upgrade your plan');
    }
  }

  void _onCaption() {
    if (!ref.read(permissionProviderImpl)['can_view_video_post_caption']) {
      showPopupComponent(
          context: context, icon: Icons.error, message: 'Please upgrade your plan');
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
              // Handle
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

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Video / loading ──────────────────────────────────────────────
        Builder(builder: (context) {
          final ctrl = _ctrl; // local for null-safe flow analysis
          if (ctrl != null && _initialized) {
            return Center(
              child: AspectRatio(
                aspectRatio: ctrl.value.aspectRatio,
                child: VideoPlayer(ctrl),
              ),
            );
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey[900]!,
            highlightColor: Colors.grey[800]!,
            child: const ColoredBox(color: Colors.black),
          );
        }),

        // ── Buffering spinner ────────────────────────────────────────────
        if (_buffering && _initialized)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
          ),

        // ── Right-side actions ───────────────────────────────────────────
        Positioned(
          right: 10,
          bottom: bottomPad + 90,
          child: _buildActionColumn(),
        ),

        // ── Profile loading overlay ──────────────────────────────────────
        if (_profileLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}