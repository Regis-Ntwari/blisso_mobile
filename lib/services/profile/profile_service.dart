import 'dart:io';

import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/models/profile_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class ProfileService {
  Future<ApiResponse> createProfile(ProfileModel profile) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: 'profiles/', body: profile.toMap(), token: accessToken);

    return response;
  }

  Future<ApiResponse> getAnyProfile(String username) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response =
        await ApiService().getData('profiles/$username/', accessToken);

    return response;
  }

  Future<ApiResponse> getMyProfile() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response =
        await ApiService().getData('profiles/my/profile/', accessToken);

    return response;
  }

  Future<ApiResponse> likeProfile(int id) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postData(
        endpoint: 'profiles/like_or_dislike/profile/$id/',
        token: accessToken,
        body: {});

    return response;
  }

  Future<ApiResponse> getAllProfiles() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response =
        await ApiService().getData('/profiles/', accessToken);

    return response;
  }

  Future<ApiResponse> updateProfileFeeling(String emoji, String caption) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postData(
        endpoint: '/profiles/my/profile/update-feeling/',
        token: accessToken,
        body: {"feeling_caption": caption, "feeling_emojis": emoji});

    return response;
  }

  Future<ApiResponse> replaceImage(File newImage, int oldId) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: '/profiles/my/profile/replace/profile-image/$oldId/',
        body: {'image': newImage},
        token: accessToken);

    return response;
  }

  Future<ApiResponse> updateProfile(TargetProfileModel myProfile) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: '/profiles/my/profile/',
        body: myProfile.profilePic == null
            ? myProfile.toMapNoProfiles()
            : myProfile.toMapNoProfile(),
        token: accessToken);

    return response;
  }

  Future<ApiResponse> updateProfilePicture(
      Map<String, dynamic> myProfile) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: '/profiles/my/profile/', body: myProfile, token: accessToken);

    return response;
  }

  Future<ApiResponse> changeLocation(Map<String, dynamic> myProfile) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: '/profiles/my/profile/update-location',
        body: myProfile,
        token: accessToken);

    return response;
  }
}
