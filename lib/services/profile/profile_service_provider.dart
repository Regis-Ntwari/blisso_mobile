// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:blisso_mobile/services/models/profile_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/profile/profile_service.dart';

class ProfileServiceProvider extends StateNotifier<ApiState> {
  final ProfileService profileService;

  ProfileServiceProvider({
    required this.profileService,
  }) : super(ApiState());

  Future<void> createProfile(ProfileModel profile) async {
    state = ApiState(isLoading: true);

    try {
      final response = await profileService.createProfile(profile);

      if (response.result == null) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);

        SharedPreferencesService.setPreference('is_profile_created', true);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getAnyProfile(String username) async {
    state = ApiState(isLoading: true);

    try {
      final response = await profileService.getAnyProfile(username);

      if (response.result == null) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getMyProfile() async {
    state = ApiState(isLoading: true);

    try {
      final response = await profileService.getMyProfile();

      if (response.result == null) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getAllProfiles() async {
    state = ApiState(isLoading: true);

    try {
      final response = await profileService.getAllProfiles();

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

final profileServiceProviderImpl =
    StateNotifierProvider<ProfileServiceProvider, ApiState>((ref) {
  return ProfileServiceProvider(profileService: ProfileService());
});
