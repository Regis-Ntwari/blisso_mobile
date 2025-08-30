import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/stories/stories_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteVideoPostProvider extends StateNotifier<ApiState> {
  final StoriesService storiesService;

  DeleteVideoPostProvider({required this.storiesService}) : super(ApiState());

  Future<void> deleteVideoPost(int id) async {
    state = ApiState(isLoading: true);

    try {
      final response = await storiesService.deleteVideoPost(id);

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

final deleteVideoPostProviderImpl =
    StateNotifierProvider<DeleteVideoPostProvider, ApiState>((ref) {
  return DeleteVideoPostProvider(storiesService: StoriesService());
});
