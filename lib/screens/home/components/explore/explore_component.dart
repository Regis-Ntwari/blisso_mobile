import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/short_story_player.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/video_controller_manager.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/stories/get_video_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreComponent extends ConsumerStatefulWidget {
  const ExploreComponent({super.key});

  @override
  ConsumerState<ExploreComponent> createState() => _ExploreComponentState();
}

class _ExploreComponentState extends ConsumerState<ExploreComponent> {
  final PageController _pageController = PageController();
  final VideoControllerManager _videoManager = VideoControllerManager();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ref.read(getVideoPostProviderImpl).data == null) {
        await ref.read(getVideoPostProviderImpl.notifier).getVideoPosts();
      }
    });
  }

  @override
  void dispose() {
    _videoManager.disposeAll();
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index, List<ShortStoryModel> videos) async {
    setState(() => _currentIndex = index);

    // Preload current, previous, next
    final toPreload = [
      if (index > 0) index - 1,
      index,
      if (index < videos.length - 1) index + 1,
    ];

    for (final i in toPreload) {
      await _videoManager.preloadController(i, videos[i].videoUrl);
    }

    // Dispose others not in preload list
    for (final key in _videoManager.activeIndexes) {
      if (!toPreload.contains(key)) {
        _videoManager.disposeController(key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(getVideoPostProviderImpl);

    if (videoState.isLoading || videoState.data == null) {
      return const LoadingScreen();
    }

    final List<ShortStoryModel> videos = (videoState.data as List)
        .map((video) => ShortStoryModel(
              id: video['id'].toString(),
              username: video['username'],
              nickname: video['nickname'],
              profilePicture: video['profile_picture_uri'],
              videoUrl: video['post_file_url'],
              description: video['caption'] ?? '',
              likes: video['likes'] ?? 0,
              shares: video['shares'] ?? 0,
              peopleLiked: video['people_liked'] ?? [],
              likedThisStory: video['liked_this_story'],
            ))
        .toList();

    return ref.read(permissionProviderImpl)['can_view_video_post'] ? PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (index) => _handlePageChanged(index, videos),
      itemBuilder: (context, index) {
        final controller = _videoManager.getController(index);
        return ShortStoryPlayer(
          video: videos[index],
          videoController: controller, // pass preloaded controller
        );
      },
    ) : PopupComponent(icon: Icons.error, message: 'Please upgrade your package!');
  }
}

