import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/stories/stories_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetVideoPostProvider extends StateNotifier<ApiState> {
  final StoriesService storiesService;

  GetVideoPostProvider({required this.storiesService}) : super(ApiState());

  Future<void> likeVideoPost(int id) async {
    state = ApiState(isLoading: false);

    try {
      final response = await storiesService.likeStory(id);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        state = ApiState(isLoading: false, data: response.result);
        
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final likeVideoPostProviderImpl =
    StateNotifierProvider<GetVideoPostProvider, ApiState>((ref) {
  return GetVideoPostProvider(storiesService: StoriesService());
});
