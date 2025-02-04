import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/users/all_user_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllUserServiceProvider extends StateNotifier<ApiState> {
  final AllUserService allUserService;

  AllUserServiceProvider({required this.allUserService}) : super(ApiState());

  Future<String> getFullName(String username) async {
    if (state.data == null) {
      await getAllUsers();
    }

    return state.data[username]['full_name'];
  }

  Future<String> getProfilePicture(String username) async {
    if (state.data == null) {
      await getAllUsers();
    }
    return state.data[username]['profile_picture_uri'];
  }

  Future<void> getAllUsers() async {
    state = ApiState(isLoading: true);

    try {
      final response = await allUserService.fetchAllUsers();

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

final allUserServiceProviderImpl =
    StateNotifierProvider<AllUserServiceProvider, ApiState>((ref) {
  return AllUserServiceProvider(allUserService: AllUserService());
});
