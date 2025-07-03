import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/profile/profile_service.dart';

class UpdateFeelingServiceProvider extends StateNotifier<ApiState> {
  final ProfileService profileService;

  UpdateFeelingServiceProvider({
    required this.profileService,
  }) : super(ApiState());

  Future<void> updateFeeling(String emoji,String caption) async {
    state = ApiState(isLoading: true);

    try {
      final response = await profileService.updateProfileFeeling(emoji, caption);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

}

final updateFeelingServiceProviderImpl =
    StateNotifierProvider<UpdateFeelingServiceProvider, ApiState>((ref) {
  return UpdateFeelingServiceProvider(profileService: ProfileService());
});
