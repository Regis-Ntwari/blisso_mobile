import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/stories/stories_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoriesServiceProvider extends StateNotifier<ApiState> {
  final StoriesService storiesService;

  StoriesServiceProvider({required this.storiesService}) : super(ApiState());

  Future<void> createStory(dynamic story) async {
    state = ApiState(isLoading: true);
    try {
      final response = await storiesService.createStory(story);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        state = ApiState(isLoading: false, data: response.result);
        getStories();
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }

  Future<void> getStories() async {
    state = ApiState(isLoading: true);

    try {
      final response = await storiesService.getStories();

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        state = ApiState(isLoading: false, data: response.result);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }

  Future<void> likeStory(int id) async {
    state = ApiState(isLoading: true);

    try {
      final response = await storiesService.likeStory(id);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
        getStories();
      } else {
        state = ApiState(isLoading: false, data: response.result);
        getStories();
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final storiesServiceProviderImpl =
    StateNotifierProvider<StoriesServiceProvider, ApiState>((ref) {
  return StoriesServiceProvider(storiesService: StoriesService());
});
