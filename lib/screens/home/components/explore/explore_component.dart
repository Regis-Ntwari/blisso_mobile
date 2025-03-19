import 'package:blisso_mobile/screens/home/components/explore/components/short_story_player.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:flutter/material.dart';

class ExploreComponent extends StatefulWidget {
  const ExploreComponent({super.key});

  @override
  State<ExploreComponent> createState() => _ExploreComponentState();
}

class _ExploreComponentState extends State<ExploreComponent> {
  final List<ShortStoryModel> videos = [
    ShortStoryModel(
      id: '1',
      username: 'user1',
      videoUrl:
          'https://d500.d2mefast.net/tb/f/fc/benson_boone_beautiful_things_official_music_video_h264_51110.mp4',
      description: 'Check out this cool video!',
    ),
    ShortStoryModel(
      id: '2',
      username: 'user2',
      videoUrl: 'https://d500.d2mefast.net/tb/3/c4/squabble_up_h264_51181.mp4',
      description: 'Amazing view from the mountains!',
    ),
    // Add more videos here
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return ShortStoryPlayer(video: videos[index]);
            }));
  }
}
