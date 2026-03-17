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

class _ExploreComponentState extends ConsumerState<ExploreComponent>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final FeedVideoControllerManager _manager = FeedVideoControllerManager();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Pause all videos when app goes to background / another tab is shown.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _manager.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      // Only resume if this route is still on top
      if (mounted) {
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          _manager.play(_currentIndex);
        }
      }
    }
  }

  /// Pause when another route is pushed on top of this one.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      _manager.pauseAll();
    } else if (route != null && route.isCurrent && _primed) {
      // Route came back into view — resume playback
      _manager.play(_currentIndex);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manager.disposeAll();
    _pageController.dispose();
    super.dispose();
  }

  List<ShortStoryModel> _mapVideos(List<dynamic> data) {
    return data.map<ShortStoryModel>((v) {
      return ShortStoryModel(
        id: v['id'].toString(),
        username: v['username'] as String? ?? '',
        nickname: v['nickname'] as String? ?? '',
        profilePicture: v['profile_picture_uri'] as String? ?? '',
        videoUrl: v['post_file_url'] as String? ?? '',
        description: v['caption'] as String? ?? '',
        likes: (v['likes'] as num?)?.toInt() ?? 0,
        shares: (v['shares'] as num?)?.toInt() ?? 0,
        views: (v['views'] as num?)?.toInt() ?? 0,
        peopleLiked: (v['people_liked'] as List?)?.cast<String>() ?? [],
        likedThisStory: v['liked_this_story'] as bool? ?? false,
      );
    }).toList();
  }

  void _onPageChanged(int index, List<ShortStoryModel> videos) {
    _currentIndex = index;

    // Play current, silence/pause all others
    _manager.play(index);
    _manager.pauseAllExcept(index);

    // Wider preload window: 2 behind, 4 ahead
    for (int i = index - 2; i <= index + 4; i++) {
      if (i >= 0 && i < videos.length) {
        _manager.preload(i, videos[i].videoUrl, muted: i != index);
      }
    }

    // Keep a generous retention buffer so back-scrolling is instant too
    _manager.retainRange(index - 3, index + 6);

    // Fetch next page earlier (when 5 from end instead of 3)
    if (index >= videos.length - 5) {
      ref.read(paginatedVideoPostProvider.notifier).loadNextPage();
    }
  }

  /// Called once when data first loads to prime the first few controllers
  /// before the user even touches the screen.
  void _primeFeed(List<ShortStoryModel> videos) {
    for (int i = 0; i <= 3 && i < videos.length; i++) {
      _manager.preload(i, videos[i].videoUrl, muted: i != 0);
    }
    // Auto-play index 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _manager.play(0);
    });
  }

  bool _primed = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedVideoPostProvider);

    if (state.isLoading && state.data.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.data.isEmpty) {
      return const Center(
        child: Text('No videos yet'),
      );
    }

    final videos = _mapVideos(state.data);

    // Prime controllers exactly once when data first arrives
    if (!_primed) {
      _primed = true;
      _primeFeed(videos);
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (i) => _onPageChanged(i, videos),
      itemBuilder: (context, index) {
        return ShortStoryPlayer(
          key: ValueKey(videos[index].id), // stable key prevents unnecessary rebuilds
          video: videos[index],
          videoController: _manager.get(index),
          isActive: index == _currentIndex,
          onTimeTrack: (start, end) => ref
              .read(watchingTimeServiceProviderImpl.notifier)
              .watchVideo(videos[index].id, start, end),
        );
      },
    );
  }
}