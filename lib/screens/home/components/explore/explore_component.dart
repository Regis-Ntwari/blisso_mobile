import 'package:blisso_mobile/screens/home/components/explore/components/feed_video_controller_manager.dart';
import 'package:blisso_mobile/services/video-post/watching_time_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blisso_mobile/services/stories/paginated_video_post_provider.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/short_story_player.dart';

class ExploreComponent extends ConsumerStatefulWidget {
  const ExploreComponent({super.key});

  @override
  ConsumerState<ExploreComponent> createState() => _ExploreComponentState();
}

class _ExploreComponentState extends ConsumerState<ExploreComponent> {
  final PageController _pageController = PageController();
  final FeedVideoControllerManager _manager = FeedVideoControllerManager();

  int _currentIndex = 0;

  @override
  void dispose() {
    _manager.disposeAll();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, List<ShortStoryModel> videos) {
    _currentIndex = index;

    _manager.play(index);
    _manager.pauseAllExcept(index);

    // Preload window
    for (int i = index - 2; i <= index + 3; i++) {
      if (i >= 0 && i < videos.length) {
        _manager.preload(i, videos[i].videoUrl, muted: i != index);
      }
    }

    _manager.retainRange(index - 4, index + 5);

    if (index >= videos.length - 3) {
      ref.read(paginatedVideoPostProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedVideoPostProvider);

    if (state.isLoading || state.data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final videos = state.data.map<ShortStoryModel>((v) {
      return ShortStoryModel(
        id: v['id'].toString(),
        username: v['username'],
        nickname: v['nickname'],
        profilePicture: v['profile_picture_uri'],
        videoUrl: v['post_file_url'],
        description: v['caption'] ?? '',
        likes: v['likes'] ?? 0,
        shares: v['shares'] ?? 0,
        views: v['views'] ?? 0,
        peopleLiked: v['people_liked'] ?? [],
        likedThisStory: v['liked_this_story'] ?? false,
      );
    }).toList();

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (i) => _onPageChanged(i, videos),
      itemBuilder: (context, index) {
        return ShortStoryPlayer(
          video: videos[index],
          videoController: _manager.get(index),
          isActive: index == _currentIndex,
          onTimeTrack: (startTimestamp, endTimestamp) => ref
              .read(watchingTimeServiceProviderImpl.notifier)
              .watchVideo(videos[index].id, startTimestamp, endTimestamp),
        );
      },
    );
  }
}
