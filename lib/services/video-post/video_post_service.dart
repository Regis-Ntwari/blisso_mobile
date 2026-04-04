import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class VideoPostService {
  Future<ApiResponse> getUserVideos() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    String username = await SharedPreferencesService.getPreference('username');

    ApiResponse response = await ApiService()
        .getData('posts/user/$username/video-posts/', accessToken);

    return response;
  }

  Future<ApiResponse> getTargetVideos(String username) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService()
        .getData('posts/user/$username/video-posts/', accessToken);

    return response;
  }

  Future<ApiResponse> updateWatchTime(
      DateTime startTimestamp, DateTime endTimestamp, String id) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postData(
        endpoint: 'posts/posts/$id/watching-time/',
        token: accessToken,
        body: {
          'start_watching': startTimestamp.toIso8601String(),
          'end_watching': endTimestamp.toIso8601String(),
        });

    print(response);

    return response;
  }

  Future<ApiResponse> viewVideo(String id) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService()
        .postData(endpoint: 'posts/posts/$id/view/', token: accessToken, body: {});

    print(response);

    return response;
  }
}
