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
  
  // Track which videos are actively playing vs preloaded
  final Set<int> _preloadedIndexes = {};
  final Set<int> _activePlayingIndexes = {};

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
    _preloadedIndexes.clear();
    _activePlayingIndexes.clear();
    super.dispose();
  }

  Future<void> _handlePageChanged(
      int index, List<ShortStoryModel> videos) async {
    setState(() => _currentIndex = index);
    
    // Update active playing indexes
    _activePlayingIndexes.clear();
    _activePlayingIndexes.add(index);
    
    // Define preload range: current, next 3, previous 2
    const preloadAhead = 3;
    const preloadBehind = 2;
    
    final preloadIndexes = <int>[];
    
    // Always preload current
    preloadIndexes.add(index);
    
    // Preload ahead
    for (int i = 1; i <= preloadAhead; i++) {
      if (index + i < videos.length) {
        preloadIndexes.add(index + i);
      }
    }
    
    // Preload behind
    for (int i = 1; i <= preloadBehind; i++) {
      if (index - i >= 0) {
        preloadIndexes.add(index - i);
      }
    }
    
    // Track which indexes we want to keep preloaded
    _preloadedIndexes.clear();
    _preloadedIndexes.addAll(preloadIndexes);
    
    // Preload videos that aren't loaded yet
    for (final i in preloadIndexes) {
      if (!_videoManager.isControllerInitialized(i)) {
        await _videoManager.preloadController(
          i, 
          videos[i].videoUrl,
          // Only mute if it's not the current video
          mute: i != index,
        );
      } else if (i == index) {
        // Ensure current video has sound when coming back to it
        _videoManager.unmuteController(i);
      }
    }
    
    // Dispose controllers that are far from current position
    // Keep a buffer of 5 videos beyond our preload range
    const bufferSize = 5;
    final maxKeepIndex = index + preloadAhead + bufferSize;
    final minKeepIndex = index - preloadBehind - bufferSize;
    
    _videoManager.retainInRange(
      minIndex: minKeepIndex,
      maxIndex: maxKeepIndex,
      currentIndex: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(getVideoPostProviderImpl);

    if (videoState.isLoading || videoState.data == null) {
      return const LoadingScreen();
    }

    final List<ShortStoryModel> videos = (videoState.data as List).map(
      (video) {
        return ShortStoryModel(
          id: video['id'].toString(),
          username: video['username'],
          nickname: video['nickname'],
          profilePicture: video['profile_picture_uri'],
          videoUrl: video['post_file_url'] ?? '',
          description: video['caption'] ?? '',
          likes: video['likes'] ?? 0,
          shares: video['shares'] ?? 0,
          peopleLiked: video['people_liked'] ?? [],
          likedThisStory: video['liked_this_story'],
        );
      },
    ).toList();

    final hasPermission =
        ref.read(permissionProviderImpl)['can_view_video_post'];

    if (!hasPermission) {
      return const PopupComponent(
        icon: Icons.error,
        message: 'Please upgrade your package to view video posts!',
      );
    }

    return MediaQuery.removePadding(
      context: context,
      removeRight: true,
      removeBottom: true,
      removeLeft: true,
      removeTop: true,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        onPageChanged: (index) => _handlePageChanged(index, videos),
        itemBuilder: (context, index) {
          final controller = _videoManager.getController(index);
          final isActive = index == _currentIndex;
          
          if (isActive && controller != null && !controller.value.isPlaying) {
            // Start playing when video becomes active
            controller.play();
            // Ensure sound is on for active video
            _videoManager.unmuteController(index);
          }
          
          return ShortStoryPlayer(
            video: videos[index],
            videoController: controller,
            isActive: isActive,
          );
        },
      ),
    );
  }
}