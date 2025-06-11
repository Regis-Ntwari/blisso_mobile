import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/video-post/video_post_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoPostServiceProvider extends StateNotifier<ApiState> {
  final VideoPostService videoPostService;

  VideoPostServiceProvider({required this.videoPostService})
      : super(ApiState());

  Future<void> getUserVideos() async {
    state = ApiState(isLoading: true);

    try {
      final response = await videoPostService.getUserVideos();

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(
            isLoading: false,
            error: response.errorMessage,
            statusCode: response.statusCode);
      } else {
        state = ApiState(
            isLoading: false,
            data: response.result,
            statusCode: response.statusCode);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString(), statusCode: 500);
    }
  }
}

final videoPostServiceProviderImpl =
    StateNotifierProvider<VideoPostServiceProvider, ApiState>((ref) {
  return VideoPostServiceProvider(videoPostService: VideoPostService());
});
