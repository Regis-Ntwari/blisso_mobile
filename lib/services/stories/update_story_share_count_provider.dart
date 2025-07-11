import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/stories/stories_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateStoryShareCountProvider extends StateNotifier<ApiState>{

  final StoriesService storiesService;

  UpdateStoryShareCountProvider({required this.storiesService}) : super(ApiState());

  Future<void> updateStoryShareCount(int id) async{
    state = ApiState(isLoading: true);
    try {
      final response = await storiesService.updateShareCount(id);

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

final updateStoryShareCountProviderImpl =
    StateNotifierProvider<UpdateStoryShareCountProvider, ApiState>((ref) {
  return UpdateStoryShareCountProvider(
      storiesService: StoriesService());
});