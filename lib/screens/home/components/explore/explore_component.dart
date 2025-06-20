import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/short_story_player.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/stories/get_video_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreComponent extends ConsumerStatefulWidget {
  const ExploreComponent({super.key});

  @override
  ConsumerState<ExploreComponent> createState() => _ExploreComponentState();
}

class _ExploreComponentState extends ConsumerState<ExploreComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      if (ref.read(getVideoPostProviderImpl).data == null) {
        await ref.read(getVideoPostProviderImpl.notifier).getVideoPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(getVideoPostProviderImpl);

    if (videoState.isLoading || videoState.data == null) {
      return const LoadingScreen();
    }

    final List<ShortStoryModel> videos = (videoState.data as List).map((video) {
      return ShortStoryModel(
          id: video['id'].toString(),
          username: video['username'],
          nickname: video['nickname'],
          profilePicture: video['profile_picture_uri'],
          videoUrl: video['post_file_url'],
          description: video['caption'] ?? '',
          likes: video['likes'] ?? 0,
          peopleLiked: video['people_liked'] ?? [],
          likedThisStory: video['liked_this_story']);
    }).toList();

    return videos.isEmpty
        ? const Center(
            child: Text('No videos available'),
          )
        : MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            removeRight: true,
            child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return ShortStoryPlayer(video: videos[index]);
                }),
          );
  }
}
