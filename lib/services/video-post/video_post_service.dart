import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class VideoPostService {
  Future<ApiResponse> getUserVideos() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    String username = await SharedPreferencesService.getPreference('username');

    ApiResponse response =
        await ApiService().getData('posts/user/$username/video-posts/', accessToken);

    return response;
  }

  Future<ApiResponse> getTargetVideos(String username) async{
    String accessToken = await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().getData('posts/user/$username/video-posts/', accessToken);

    return response;
  }
}
