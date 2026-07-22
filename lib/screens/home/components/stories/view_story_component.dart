import 'dart:convert';
import 'dart:math';

import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/home/components/stories/share_short_story_component.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/stories/delete_story_provider.dart';
import 'package:blisso_mobile/services/video-post/view_video_service_provider.dart';
import 'package:blisso_mobile/services/video-post/watching_time_service_provider.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';
import 'package:blisso_mobile/services/stories/stories_service_provider.dart';

class ViewStoryComponent extends ConsumerStatefulWidget {
  const ViewStoryComponent({super.key});

  @override
  ConsumerState<ViewStoryComponent> createState() => _ViewStoryPageState();
}

class _ViewStoryPageState extends ConsumerState<ViewStoryComponent> {
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  List<Map<String, dynamic>> _stories = [];
  bool _loaded = false;

  String _nickname = '';
  String _username = '';

  bool _liked = false;
  bool _sendingReply = false;
  bool _profileLoading = false;

  DateTime? _trackStart;
  int? _trackIndex;

  final TextEditingController _replyCtrl = TextEditingController();

  // ── Init / dispose ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPrefs();
      _loadData();
    });
  }

  @override
  void dispose() {
    _trackStart = null;
    _trackIndex = null;
    // Pause + dispose all controllers so nothing plays in background
    for (final c in _controllers.values) {
      c.pause();
      c.dispose();
    }
    _controllers.clear();
    _replyCtrl.dispose();
    super.dispose();
  }

  // ── Prefs ────────────────────────────────────────────────────────────────

  Future<void> _initPrefs() async {
    final nick = await SharedPreferencesService.getPreference('nickname') ?? '';
    final user = await SharedPreferencesService.getPreference('username') ?? '';
    if (mounted) setState(() { _nickname = nick; _username = user; });
  }

  // ── Data ─────────────────────────────────────────────────────────────────

  void _loadData() {
    final params = Routemaster.of(context).currentRoute.queryParameters;
    final raw = params['data'];
    if (raw == null) return;
    try {
      _stories = List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (_) {
      return;
    }
    if (_stories.isEmpty) return;
    _loaded = true;
    _preload(_currentIndex);
    _beginTracking(_currentIndex);
    if (mounted) setState(() {});
  }

  // ── Video controller pool ────────────────────────────────────────────────

  void _preload(int center) {
    final keep = <int>{};
    for (int i = center - 1; i <= center + 1; i++) {
      if (i >= 0 && i < _stories.length) keep.add(i);
    }

    for (final k in _controllers.keys.toList()) {
      if (!keep.contains(k)) {
        _controllers[k]?.pause();
        _controllers[k]?.dispose();
        _controllers.remove(k);
      }
    }

    for (final i in keep) {
      if (_stories[i]['post_type'] == 'VIDEO' && !_controllers.containsKey(i)) {
        _initController(i, playImmediately: i == center);
      }
    }

    for (final entry in _controllers.entries) {
      if (entry.key == center) {
        if (entry.value.value.isInitialized) entry.value.play();
      } else {
        entry.value.pause();
      }
    }
  }

  void _initController(int index, {required bool playImmediately}) {
    final url = _stories[index]['post_file_url'] as String? ?? '';
    if (url.isEmpty) return;
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[index] = ctrl;
    ctrl.initialize().then((_) {
      if (!mounted) return;
      if (playImmediately && _currentIndex == index) ctrl.play();
      setState(() {});
    }).catchError((_) {});
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void _close() {
    _endTracking();
    // Pause the current video explicitly before popping
    _controllers[_currentIndex]?.pause();
    if (mounted) Navigator.of(context).pop();
  }

  void _goTo(int index) {
    _endTracking();
    if (index < 0 || index >= _stories.length) {
      _controllers[_currentIndex]?.pause();
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() { _currentIndex = index; _liked = false; });
    _preload(index);
    _beginTracking(index);
  }

  void _next() => _goTo(_currentIndex + 1);
  void _prev() => _goTo(_currentIndex - 1);

  // ── Tracking ─────────────────────────────────────────────────────────────

  void _beginTracking(int index) {
    final storyId = _stories[index]['id']?.toString() ?? '';
    if (storyId.isNotEmpty) {
      ref.read(viewVideoServiceProviderImpl.notifier).viewVideo(storyId);
    }
    _trackStart = DateTime.now();
    _trackIndex = index;
  }

  void _endTracking() {
    if (_trackStart == null || _trackIndex == null) return;
    final start = _trackStart!;
    final idx = _trackIndex!;
    _trackStart = null;
    _trackIndex = null;
    if (!mounted) return;
    try {
      final storyId = _stories[idx]['id']?.toString() ?? '';
      if (storyId.isNotEmpty) {
        ref.read(watchingTimeServiceProviderImpl.notifier)
            .watchVideo(storyId, start, DateTime.now());
      }
    } catch (_) {}
  }

  // ── Like ─────────────────────────────────────────────────────────────────

  void _toggleLike() {
    final storyId = _stories[_currentIndex]['id']?.toString();
    if (storyId == null) return;
    ref.read(storiesServiceProviderImpl.notifier).likeStory(int.parse(storyId));
    setState(() => _liked = !_liked);
  }

  // ── Caption modal ─────────────────────────────────────────────────────────

  void _showFullCaption(String caption) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.92),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    caption,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reply ────────────────────────────────────────────────────────────────

  String _hex12() {
    final ts = DateTime.now().millisecondsSinceEpoch
        .toRadixString(16).padLeft(16, '0');
    final rnd = List.generate(
        4, (_) => Random().nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return ts + rnd;
  }

  Future<void> _sendReply(String toUsername, String name) async {
    if (_sendingReply) return;
    setState(() => _sendingReply = true);

    await ref.read(addMessageRequestServiceProviderImpl.notifier)
        .sendMessageRequest(toUsername);

    if (!mounted) return;
    final resp = ref.read(addMessageRequestServiceProviderImpl);

    if (resp.error == null) {
      if (resp.statusCode == 200) {
        final chatState = ref.read(chatServiceProviderImpl);
        if (chatState.data == null || chatState.data.isEmpty) {
          await ref.read(chatServiceProviderImpl.notifier).getMessages();
        }
        if (!mounted) return;
        try {
          ref.read(webSocketNotifierProvider.notifier).sendMessage(
            ChatMessageModel(
              messageId: _hex12(),
              parentId: _stories[_currentIndex]['id']?.toString() ?? '',
              parentContent: 'Story',
              contentFileType: _stories[_currentIndex]['id']?.toString() ?? '',
              sender: _username,
              receiver: toUsername,
              messageStatus: 'unseen',
              action: 'created',
              content: _replyCtrl.text,
              isFileIncluded: false,
              createdAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );
          _replyCtrl.clear();
        } catch (_) {}
      } else if (resp.statusCode == 201) {
        showPopupComponent(context: context, icon: Icons.verified,
            iconColor: Colors.green[800],
            message: 'Message request sent to $name!');
      } else {
        showPopupComponent(context: context, icon: Icons.error,
            iconColor: Colors.red,
            message: resp.error ?? 'Something went wrong');
      }
    } else {
      showPopupComponent(context: context, icon: Icons.error,
          message: resp.error ?? 'Something went wrong');
    }

    if (mounted) setState(() => _sendingReply = false);
  }

  String _compact(num v) {
    if (v < 1000) return v.toString();
    String fmt(num n, String s) {
      final f = n.toStringAsFixed(1);
      return '${f.endsWith('.0') ? f.substring(0, f.length - 2) : f}$s';
    }
    if (v < 1000000) return fmt(v / 1000, 'k');
    if (v < 1000000000) return fmt(v / 1000000, 'M');
    return fmt(v / 1000000000, 'B');
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: GlobalColors.primaryColor)),
      );
    }

    final story = _stories[_currentIndex];
    final isMyStory = story['nickname'] == _nickname;
    final isVideo = story['post_type'] == 'VIDEO';
    final videoCtrl = _controllers[_currentIndex];
    final topPad = MediaQuery.of(context).padding.top;
    final screenW = MediaQuery.of(context).size.width;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final alreadyLiked = (story['liked_this_story'] as bool? ?? false) || _liked;

    final caption = story['caption'] as String?;
    final canSeeCaption = ref.read(permissionProviderImpl)['can_view_short_story_caption'] as bool? ?? false;
    final canReply = ref.read(permissionProviderImpl)['can_reply_short_story'] as bool? ?? false;

    // Bottom bar height: used to correctly position author + caption above it
    // own story bar ≈ 52 + bottomPad, others bar ≈ 64 + bottomPad
    final bottomBarH = (isMyStory ? 52.0 : 64.0) + bottomPad;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── 1. Media ──────────────────────────────────────────────────────
          if (isVideo)
            videoCtrl != null && videoCtrl.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: videoCtrl.value.aspectRatio,
                      child: VideoPlayer(videoCtrl),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(
                    strokeWidth: 3, color: GlobalColors.primaryColor))
          else
            CachedNetworkImage(
              imageUrl: story['post_file_url'] as String? ?? '',
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(child: CircularProgressIndicator(
                  strokeWidth: 3, color: GlobalColors.primaryColor)),
              errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38)),
            ),

          // ── 2. Tap zones (prev / next) ────────────────────────────────────
          Positioned(
            top: 0,
            bottom: bottomBarH,
            left: 0,
            width: screenW * 0.35,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _prev,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: 0,
            bottom: bottomBarH,
            right: 0,
            width: screenW * 0.65,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _next,
              child: const SizedBox.expand(),
            ),
          ),

          // ── 3. Progress strips ────────────────────────────────────────────
          Positioned(
            top: topPad + 6,
            left: 10,
            right: 10,
            child: Row(
              children: List.generate(_stories.length, (i) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: i <= _currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.38),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )),
            ),
          ),

          // ── 4. Close ──────────────────────────────────────────────────────
          Positioned(
            top: topPad + 16,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 22),
              onPressed: _close,
            ),
          ),

          // ── 5. More options (own story) ───────────────────────────────────
          if (isMyStory)
            Positioned(
              top: topPad + 16,
              right: 4,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF1C1C1C),
                onSelected: (v) async {
                  setState(() => _profileLoading = true);
                  if (v == 'share') {
                    if (ref.read(permissionProviderImpl)['can_share_short_story']) {
                      showShareShortStoryModal(context, story['id']);
                    } else {
                      showPopupComponent(context: context, icon: Icons.error,
                          message: 'Please upgrade your plan');
                    }
                  } else {
                    await ref.read(deleteStoryProviderImpl.notifier).deleteStory(story['id']);
                    await ref.read(storiesServiceProviderImpl.notifier).getStories();
                    if (mounted) Navigator.of(context).pop();
                  }
                  if (mounted) setState(() => _profileLoading = false);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'share',
                      child: Text('Share Story', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'delete',
                      child: Text('Delete Story', style: TextStyle(color: Colors.redAccent))),
                ],
              ),
            ),

          // ── 6. Bottom overlay: author + caption stacked above bottom bar ──
          //
          //  Layout from bottom up:
          //    [bottom bar]            ← fixed height = bottomBarH
          //    [author chip]           ← 42px
          //    [caption (max 3 lines)] ← variable, tap to expand
          //
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomBarH,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Caption (above author) ───────────────────────────────
                

                // ── Author chip ──────────────────────────────────────────
                GestureDetector(
                  onTap: () async {
                    if (!ref.read(permissionProviderImpl)['can_view_profile_detail']) {
                      showPopupComponent(context: context, icon: Icons.error,
                          message: 'Please upgrade your plan');
                      return;
                    }
                    setState(() => _profileLoading = true);
                    try {
                      await ref.read(anyProfileServiceProviderImpl.notifier)
                          .getAnyProfile(story['username'] as String);
                      if (!mounted) return;
                      final data = ref.read(anyProfileServiceProviderImpl).data;
                      ref.read(targetProfileProvider.notifier).updateTargetProfile(
                          TargetProfileModel.fromMap(data as Map<String, dynamic>));
                      Routemaster.of(context).push('/homepage/target-profile');
                    } catch (_) {
                      if (mounted) showSnackBar(context, 'Failed to load profile');
                    }
                    if (mounted) setState(() => _profileLoading = false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundImage: CachedNetworkImageProvider(
                              story['profile_picture_uri'] as String? ?? ''),
                          onBackgroundImageError: (_, __) {},
                          child: story['profile_picture_uri'] == null
                              ? const Icon(Icons.person, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isMyStory
                              ? 'My Day'
                              : story['nickname'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(
                                blurRadius: 4,
                                color: Colors.black87,
                                offset: Offset(0, 1))],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (caption != null && caption.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showFullCaption(
                      canSeeCaption ? caption : 'Upgrade to view caption',
                    ),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              canSeeCaption ? caption : 'Upgrade to view caption',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),
                          // "more" hint if text likely overflows
                          if (canSeeCaption && caption.length > 80)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Text(
                                'more',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── 7a. Bottom bar — others' story ────────────────────────────────
          // ── 7a. Bottom bar — others' story ────────────────────────────────
if (!isMyStory)
  Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Padding(
      // This line is the fix: It adds padding equal to the keyboard height
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        color: Colors.black.withOpacity(0.55),
        padding: EdgeInsets.fromLTRB(4, 6, 4, bottomPad + 10),
        child: Row(
          children: [
            // Like
            IconButton(
              onPressed: _toggleLike,
              icon: Icon(
                alreadyLiked ? Icons.favorite : Icons.favorite_border,
                color: alreadyLiked ? GlobalColors.primaryColor : Colors.white,
                size: 22,
              ),
            ),

            // Reply field
            Expanded(
              child: canReply
                  ? Container(
                      height: 38, // Slightly increased height for better visibility
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: TextField(
                        controller: _replyCtrl,
                        // Ensure focus doesn't cause issues
                        autofocus: false, 
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Reply…',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(60)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Upgrade to reply',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 12)),
                    ),
            ),

            // Send
            if (canReply)
              _sendingReply
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send,
                          color: Colors.white, size: 18),
                      onPressed: () {
                        if (_replyCtrl.text.trim().isNotEmpty) {
                          _sendReply(
                            story['username'] as String? ?? '',
                            story['name'] as String? ?? '',
                          );
                          // Unfocus keyboard after sending
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
          ],
        ),
      ),
    ),
  ),

          // ── 7b. Bottom bar — own story stats ──────────────────────────────
          if (isMyStory)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                padding: EdgeInsets.fromLTRB(0, 8, 0, bottomPad + 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_compact(story['likes'] as num? ?? 0),
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(width: 4),
                    Icon(Icons.favorite, size: 16, color: GlobalColors.primaryColor),
                    const SizedBox(width: 18),
                    Text(_compact(story['views'] as num? ?? 0),
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.remove_red_eye, size: 16, color: Colors.white60),
                  ],
                ),
              ),
            ),

          // ── 8. Profile-loading overlay ────────────────────────────────────
          if (_profileLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}