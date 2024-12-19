import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/auth/user_service.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
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

      if (!StatusCodes.codes.contains(response.statusCode)) {
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

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);

        SharedPreferencesService.setPreference(
            "accessToken", response.result['access']);

        if (response.result['profile_picture'] != null) {
          SharedPreferencesService.setPreference(
              'profile_picture', response.result['profile_picture']);
        }

        SharedPreferencesService.setPreference(
            'username', response.result['username']);

        SharedPreferencesService.setPreference(
            'firstname', response.result['first_name']);

        SharedPreferencesService.setPreference(
            'lastname', response.result['last_name']);

        SharedPreferencesService.setPreference(
            "refreshToken", response.result['refresh']);

        SharedPreferencesService.setPreference(
            'is_profile_created', response.result['has_profile']);

        SharedPreferencesService.setPreference(
            'is_target_snapshots', response.result['has_target_snapshots']);

        SharedPreferencesService.setPreference(
            'is_my_snapshots', response.result['has_my_snapshots']);

        SharedPreferencesService.setPreference(
            'is_profile_completed', response.result['has_pictures']);

        SharedPreferencesService.setPreference("isRegistered", true);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> generateLoginCode() async {
    state = ApiState(isLoading: true);

    try {
      final response = await _userService.generateLoginCode();
      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loginBio() async {
    state = ApiState(isLoading: true);
    try {
      final response = await _userService.loginViaBiometrics();
      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);

        SharedPreferencesService.setPreference(
            "accessToken", response.result['access']);

        SharedPreferencesService.setPreference(
            'profile_picture', response.result['profile_picture']);

        SharedPreferencesService.setPreference(
            'username', response.result['username']);

        SharedPreferencesService.setPreference(
            'firstname', response.result['first_name']);

        SharedPreferencesService.setPreference(
            'lastname', response.result['last_name']);

        SharedPreferencesService.setPreference(
            "refreshToken", response.result['refresh']);

        SharedPreferencesService.setPreference(
            'is_profile_created', response.result['has_profile']);

        SharedPreferencesService.setPreference(
            'is_target_snapshots', response.result['has_target_snapshots']);

        SharedPreferencesService.setPreference(
            'is_my_snapshots', response.result['has_my_snapshots']);

        SharedPreferencesService.setPreference(
            'is_profile_completed', response.result['has_pictures']);

        SharedPreferencesService.setPreference("isRegistered", true);
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
