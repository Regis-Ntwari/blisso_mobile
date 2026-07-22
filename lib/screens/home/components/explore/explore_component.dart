import 'package:blisso_mobile/screens/home/components/explore/components/feed_video_controller_manager.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/video_feed_state_provider.dart';
import 'package:blisso_mobile/services/video-post/video_post_service_provider.dart';
import 'package:blisso_mobile/services/video-post/watching_time_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blisso_mobile/services/stories/paginated_video_post_provider.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/short_story_player.dart';

/// Whether the Explore (videos) tab is currently the active tab.
final exploreTabActiveProvider = StateProvider<bool>((ref) => false);

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
  bool _primed = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mark this tab as active
      if (ref.read(paginatedVideoPostProvider).data.isEmpty) {
        ref.read(paginatedVideoPostProvider.notifier).loadFirstPage();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _manager.deactivate();
    } else if (state == AppLifecycleState.resumed) {
      _resumeIfEligible();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == null) return;

    if (!route.isCurrent) {
      // A new route was pushed on top — silence everything immediately.
      _manager.deactivate();
    } else {
      // Route is back on top (e.g. popped back from video player).
      _resumeIfEligible();
    }
  }

  @override
  void deactivate() {
    // Fires during the build phase when the element leaves the tree (tab
    // switch) — earlier than dispose(), stopping audio immediately.
    _manager.deactivate();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manager.disposeAll();
    _pageController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Resume playback only when both the route is on top AND the tab is active.
  void _resumeIfEligible() {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    final tabActive = ref.read(exploreTabActiveProvider);
    if (route != null && route.isCurrent && tabActive && _primed) {
      _manager.activate();
      _manager.play(_currentIndex);
    }
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
        postThumbnailUrl: v['post_video_thumbnail_url'] as String? ?? '',
      );
    }).toList();
  }

  void _onPageChanged(int index, List<ShortStoryModel> videos) {
    _currentIndex = index;

    _manager.play(index);
    _manager.pauseAllExcept(index);

    // Preload: 2 behind, 4 ahead
    for (int i = index - 2; i <= index + 4; i++) {
      if (i >= 0 && i < videos.length) {
        _manager.preload(i, videos[i].videoUrl, muted: i != index);
      }
    }

    _manager.retainRange(index - 3, index + 6);

    if (index >= videos.length - 5) {
      ref.read(paginatedVideoPostProvider.notifier).loadNextPage();
    }
  }

  void _primeFeed(List<ShortStoryModel> videos) {
    for (int i = 0; i <= 3 && i < videos.length; i++) {
      _manager.preload(i, videos[i].videoUrl, muted: i != 0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Only auto-play if this tab is currently active
      if (ref.read(exploreTabActiveProvider)) {
        _manager.activate();
        _manager.play(0);
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedVideoPostProvider);

    // Tab active/inactive — this is the primary switch for the explore tab.
    ref.listen<bool>(exploreTabActiveProvider, (prev, isActive) {
      if (!isActive) {
        _manager.deactivate();
      } else if (_primed) {
        // Tab came back into focus — only play if route is also on top.
        _resumeIfEligible();
      }
    });

    // inside build(), after the existing ref.listen for exploreTabActiveProvider

    ref.listen<bool>(videoFeedSuppressedProvider, (_, suppressed) {
      if (suppressed) {
        _manager.deactivate();
      } else if (_primed) {
        _resumeIfEligible(); // resumes only if tab + route are also active
      }
    });

    if (state.isLoading && state.data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.data.isEmpty) {
      return const Center(child: Text('No videos yet'));
    }

    final videos = _mapVideos(state.data);

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
          key: ValueKey(videos[index].id),
          video: videos[index],
          videoController: _manager.get(index),
          isActive: index == _currentIndex,
          onTimeTrack: (start, end) {
            if (!mounted) return;
            ref
                .read(watchingTimeServiceProviderImpl.notifier)
                .watchVideo(videos[index].id, start, end);
          },
        );
      },
    );
  }
}
