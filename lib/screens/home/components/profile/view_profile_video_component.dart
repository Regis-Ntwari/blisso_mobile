import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/home/components/explore/components/short_story_player.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/stories/delete_video_post_provider.dart';
import 'package:blisso_mobile/services/stories/get_one_story_provider.dart';
import 'package:blisso_mobile/services/video-post/user_video_post_service_provider.dart';
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
        views: videoState.data['views'],
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
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Video'),
                        content: const Text('Are you sure you want to delete this video?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(deleteVideoPostProviderImpl.notifier)
                          .deleteVideoPost(widget.videoId);
                      final deleteState = ref.read(deleteVideoPostProviderImpl);
                      if (deleteState.error == null) {
                        ref.read(userVideoPostServiceProviderImpl.notifier).getUserVideos();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          showSnackBar(context, 'Video deleted successfully');
                        }
                      } else {
                        if (context.mounted) {
                          showSnackBar(context, deleteState.error!);
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Video', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              removeRight: true,
              child: ShortStoryPlayer(video: story, isActive: true,))),
    );
  }
}
