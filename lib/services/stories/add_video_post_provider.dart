import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/stories/stories_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddVideoPostProvider extends StateNotifier<ApiState> {
  final StoriesService storiesService;

  AddVideoPostProvider({required this.storiesService}) : super(ApiState());

  Future<void> addVideoPost(dynamic story) async {
    state = ApiState(isLoading: true);

    try {
      final response = await storiesService.postVideoPosts(story);

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

final addVideoPostProviderImpl =
    StateNotifierProvider<AddVideoPostProvider, ApiState>((ref) {
  return AddVideoPostProvider(storiesService: StoriesService());
});
