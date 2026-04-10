import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/video-post/video_post_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchingTimeServiceProvider extends StateNotifier<ApiState>{

  final VideoPostService videoPostService;

  WatchingTimeServiceProvider({required this.videoPostService}) : super(ApiState(isLoading: true));

  Future<void> watchVideo(String id, DateTime startTime, DateTime endTime) async{
    print("Watching video with id: $id from $startTime to $endTime");
    try {
      await videoPostService.updateWatchTime(startTime, endTime, id);


    } catch (e) {
      
    }
  }
}

final watchingTimeServiceProviderImpl = StateNotifierProvider<WatchingTimeServiceProvider, ApiState>((_) {
  return WatchingTimeServiceProvider(videoPostService: VideoPostService());
});