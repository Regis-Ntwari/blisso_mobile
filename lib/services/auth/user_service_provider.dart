import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/auth/user_service.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
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

        SharedPreferencesService.setPreference('id', response.result['id']);

        SharedPreferencesService.setPreference(
            'username', response.result['username']);

        SharedPreferencesService.setPreference(
            'firstname', response.result['first_name']);

        SharedPreferencesService.setPreference(
            'lastname', response.result['last_name']);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loginUser(String username, String password) async {
    state = ApiState(isLoading: true);

    try {
      final response = await _userService.loginUser(username, password);

      if (response.result == null) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);

        SharedPreferencesService.setPreference(
            "accessToken", response.result['']);
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
