import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/video-post/video_post_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewVideoServiceProvider extends StateNotifier<ApiState> {

  final VideoPostService videoPostService;

  ViewVideoServiceProvider({required this.videoPostService})
      : super(ApiState(isLoading: true));

  Future<void> viewVideo(String id) async {
    state = ApiState(isLoading: true);

    try {
      final response = await videoPostService.viewVideo(id);

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

final viewVideoServiceProviderImpl =
    StateNotifierProvider<ViewVideoServiceProvider, ApiState>((ref) {
  return ViewVideoServiceProvider(videoPostService: VideoPostService());
});