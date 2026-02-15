import 'dart:io';

import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/models/profile_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class ProfileService {
  Future<ApiResponse> createProfile(ProfileModel profile) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postFormDataRequest(
      endpoint: 'profiles/',
      body: profile.toMap(),
      token: accessToken,
    );
  }

  Future<ApiResponse> getAnyProfile(String username) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().getData('profiles/$username/', accessToken);
  }

  Future<ApiResponse> getMyProfile() async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().getData('profiles/my/profile/', accessToken);
  }

  Future<ApiResponse> likeProfile(int id) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postData(
      endpoint: 'profiles/like_or_dislike/profile/$id/',
      token: accessToken,
      body: {},
    );
  }

  /* ---------------- PROFILES (WITH SEARCH) ---------------- */

  Future<ApiResponse> getAllProfiles({
    int page = 1,
    double? latitude,
    double? longitude,
    String? filterOption,
    String? filterValue,
  }) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    final query = <String>[
      if (latitude != null) 'latitude=$latitude',
      if (longitude != null) 'longitude=$longitude',
      'page=$page',
      if (filterOption != null && filterValue != null)
        'filter_option=${filterOption.toLowerCase()}',
      if (filterValue != null) 'filter_value=$filterValue',
    ].join('&');

    return ApiService().getData('/profiles/?$query', accessToken);
  }

  /* ---------------- OTHER METHODS (UNCHANGED) ---------------- */

  Future<ApiResponse> updateProfileFeeling(String emoji, String caption) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postData(
      endpoint: '/profiles/my/profile/update-feeling/',
      token: accessToken,
      body: {
        "feeling_caption": caption,
        "feeling_emojis": emoji,
      },
    );
  }

  Future<ApiResponse> replaceImage(File newImage, int oldId) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postFormDataRequest(
      endpoint: '/profiles/my/profile/replace/profile-image/$oldId/',
      body: {'image': newImage},
      token: accessToken,
    );
  }

  Future<ApiResponse> updateProfile(TargetProfileModel myProfile) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postFormDataRequest(
      endpoint: '/profiles/my/profile/',
      body: myProfile.profilePic == null
          ? myProfile.toMapNoProfiles()
          : myProfile.toMapNoProfile(),
      token: accessToken,
    );
  }

  Future<ApiResponse> updateProfilePicture(
      Map<String, dynamic> myProfile) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postFormDataRequest(
      endpoint: '/profiles/my/profile/',
      body: myProfile,
      token: accessToken,
    );
  }

  Future<ApiResponse> changeLocation(Map<String, dynamic> myProfile) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postFormDataRequest(
      endpoint: '/profiles/my/profile/update-location',
      body: myProfile,
      token: accessToken,
    );
  }
}
