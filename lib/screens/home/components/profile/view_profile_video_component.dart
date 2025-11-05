import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/short_story_player.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/stories/get_one_story_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewProfileVideoComponent extends ConsumerStatefulWidget {
  final int videoId;
  const ViewProfileVideoComponent({super.key, required this.videoId});

  @override
  ConsumerState<ViewProfileVideoComponent> createState() => _ChatViewVideoState();
}

class _ChatViewVideoState extends ConsumerState<ViewProfileVideoComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(getOneStoryProviderImpl.notifier)
          .getOneStory(widget.videoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(getOneStoryProviderImpl);

    if (videoState.isLoading || videoState.data == null) {
      return const LoadingScreen();
    }

    /**id: video['id'].toString(),
          username: video['username'],
          nickname: video['nickname'],
          profilePicture: video['profile_picture_uri'],
          videoUrl: video['post_file_url'],
          description: video['caption'] ?? '',
          likes: video['likes'] ?? 0,
          peopleLiked: video['people_liked'] ?? [],
          likedThisStory: video['liked_this_story']); */

    final story = ShortStoryModel(
        id: videoState.data['id'].toString(),
        username: videoState.data['username'],
        nickname: videoState.data['nickname'],
        profilePicture: videoState.data['profile_picture_uri'],
        videoUrl: videoState.data['post_file_url'],
        description: videoState.data['caption'],
        likes: videoState.data['likes'],
        shares: videoState.data['shares'],
        peopleLiked: videoState.data['people_liked'],
        likedThisStory: videoState.data['liked_this_story']);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            title: const Text('Video', style: TextStyle(color: Colors.white),),
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                )),
          ),
          body: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              removeRight: true,
              child: ShortStoryPlayer(video: story, isActive: true,))),
    );
  }
}
