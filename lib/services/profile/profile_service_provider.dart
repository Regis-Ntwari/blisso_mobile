// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:blisso_mobile/services/models/profile_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
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

      if (!StatusCodes.codes.contains(response.statusCode)) {
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

      if (!StatusCodes.codes.contains(response.statusCode)) {
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

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  void addSnapshot(Map<String, dynamic> snap) {
    state = ApiState(data: {...state.data, 'lifesnapshots' : [...state.data['lifesnapshots'], snap]}, isLoading: false);
  }

  void removeSnapshotById(int id) {
  final current = List<Map<String, dynamic>>.from(state.data['lifesnapshots'] ?? []);
  final updated = current.where((s) => s['id'] != id).toList();

  state = ApiState(
    data: {
      ...state.data,
      'lifesnapshots': updated,
    },
    isLoading: false,
  );
}

  Future<void> likeProfile(int id) async{
    //state = ApiState(isLoading: true);

    try {
      final response = await profileService.likeProfile(id);

      print(response);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        //state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        //state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      //state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> getAllProfiles() async {
    state = ApiState(isLoading: true);

    try {
      final response = await profileService.getAllProfiles();

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  String? getFullName(String username) {
    if (state.data == null) {
      return 'Unknown User';
    }
    for (var profile in state.data) {
      if (profile['user']['username'] == username) {
        return profile['user']['first_name'] +
            ' ' +
            profile['user']['last_name'];
      }
    }
    return 'Unknown User';
  }

  String? getProfilePicture(String username) {
    if (state.data == null) {
      return 'https://images.unsplash.com/photo-1711560707076-d50fbf8a3a26?q=80&w=1512';
    }
    for (var profile in state.data) {
      if (profile['user']['username'] == username) {
        return profile['profile_picture_uri'];
      }
    }
    return 'https://images.unsplash.com/photo-1711560707076-d50fbf8a3a26?q=80&w=1512';
  }
}

final profileServiceProviderImpl =
    StateNotifierProvider<ProfileServiceProvider, ApiState>((ref) {
  return ProfileServiceProvider(profileService: ProfileService());
});
