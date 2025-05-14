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
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        description: 'Check out this cool video!',
        likes: 300),
    ShortStoryModel(
        id: '2',
        username: 'user2',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        description: 'Amazing view from the mountains!',
        likes: 100),
    ShortStoryModel(
        id: '3',
        username: 'user3',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        description: 'Amazing view!',
        likes: 200),
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
