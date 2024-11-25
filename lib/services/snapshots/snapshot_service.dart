import 'dart:io';

import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class SnapshotService {
  Future<ApiResponse> fetchProfileSnapshots() async {
    String token = await SharedPreferencesService.getPreference('accessToken');
    final response =
        await ApiService().getData('fixtures/lifesnapshots/', token);

    return response;
  }

  Future<ApiResponse> postProfileSnapshots(List<int> snapshots) async {
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().postData(
        endpoint: '/profiles/my/profile/add/life-snapshots/',
        body: {'life_snapshots': snapshots},
        token: token);

    return response;
  }

  Future<ApiResponse> postTargetProfileSnapshots(
      List<dynamic> snapshots) async {
    String token = await SharedPreferencesService.getPreference("accessToken");

    final response = await ApiService().postData(
        endpoint: '/profiles/my/profile/add/target-life-snapshots/',
        body: {'target_life_snapshots': snapshots},
        token: token);

    return response;
  }

  Future<ApiResponse> postImages(List<File> images) async {
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().postFormDataRequest(
        endpoint: '/profiles/my/profile/add/profile-image/',
        body: {'images': images},
        token: token);

    return response;
  }
}
