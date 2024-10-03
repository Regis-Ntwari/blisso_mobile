import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/auth/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserServiceProvider extends StateNotifier<ApiState> {
  final UserService _userService;

  UserServiceProvider(this._userService) : super(ApiState());

  Future<void> registerUser(
      String username, firstname, lastname, authType) async {
    state = ApiState(isLoading: true);

    try {
      final response = await _userService.registerUser(
          username, firstname, lastname, authType);

      if (response.result == null) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }
}

final userServiceProviderImpl =
    StateNotifierProvider<UserServiceProvider, ApiState>((ref) {
  return UserServiceProvider(UserService());
});
