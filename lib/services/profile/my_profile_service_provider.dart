import 'dart:io';

import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/profile/profile_service.dart';

class MyProfileServiceProvider extends StateNotifier<ApiState> {
  final ProfileService profileService;

  MyProfileServiceProvider({
    required this.profileService,
  }) : super(ApiState());

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

  Future<void> replaceImage(File newImage, int oldImage) async {
    //state = ApiState(isLoading: true);

    try {
      final response = await profileService.replaceImage(newImage, oldImage);
      print(response);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        //state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        //state = ApiState(data: response.result, isLoading: false);
        getMyProfile();
      }
    } catch (e) {
      //state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  void addSnapshot(Map<String, dynamic> snap) {
    state = ApiState(data: {
      ...state.data,
      'lifesnapshots': [...state.data['lifesnapshots'], snap]
    }, isLoading: false);
  }

  void removeSnapshotById(int id) {
    final current =
        List<Map<String, dynamic>>.from(state.data['lifesnapshots'] ?? []);
    final updated = current.where((s) => s['id'] != id).toList();

    state = ApiState(
      data: {
        ...state.data,
        'lifesnapshots': updated,
      },
      isLoading: false,
    );
  }

  void addTargetSnapshot(Map<String, dynamic> target) {
    state = ApiState(data: {
      ...state.data,
      'target_lifesnapshots': [...state.data['target_lifesnapshots'], target]
    }, isLoading: false);
  }

  void removeTargetSnapshot(int id) {
    final current =
        List<Map<String, dynamic>>.from(state.data['target_lifesnapshots'] ?? []);
    final updated = current.where((s) => s['id'] != id).toList();

    state = ApiState(
      data: {
        ...state.data,
        'target_lifesnapshots': updated,
      },
      isLoading: false,
    );
  }

  void updateField(String fieldname, String value) {
    Map<String, dynamic> updatedProfile = {...state.data, fieldname: value};
    state = ApiState(isLoading: false, data: updatedProfile, statusCode: 200);
  }

  Future<void> updateProfile(TargetProfileModel profileModel) async {
    // state = ApiState(isLoading: true);

    try {
      final response = await profileService.updateProfile(profileModel);
      print(response);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        //state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        //state = ApiState(data: response.result, isLoading: false);
        getMyProfile();
      }
    } catch (e) {
      //state = ApiState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateProfilePicture(
      TargetProfileModel profileModel, File newImage) async {
    state = ApiState(isLoading: true);

    try {
      Map<String, dynamic> profile = profileModel.toMap();
      profile['profile_pic'] = newImage;
      final response = await profileService.updateProfilePicture(profile);

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

final myProfileServiceProviderImpl =
    StateNotifierProvider<MyProfileServiceProvider, ApiState>((ref) {
  return MyProfileServiceProvider(profileService: ProfileService());
});
