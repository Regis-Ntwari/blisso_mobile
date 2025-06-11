import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class StoriesService {
  Future<ApiResponse> createStory(dynamic story) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');
    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: 'posts/stories/', body: story, token: accessToken);

    return response;
  }

  Future<ApiResponse> getStories() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    print(accessToken);

    ApiResponse response =
        await ApiService().getData('posts/stories/', accessToken);

    return response;
  }

  Future<ApiResponse> likeStory(int id) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postData(
        endpoint: 'posts/posts/$id/like/', token: accessToken, body: {});

    return response;
  }

  Future<ApiResponse> getOneStory(int id) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response =
        await ApiService().getData('posts/stories/$id', accessToken);

    return response;
  }

  Future<ApiResponse> postVideoPosts(dynamic story) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: 'posts/video-posts/', body: story, token: accessToken);

    return response;
  }

  Future<ApiResponse> getVideoPosts() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response =
        await ApiService().getData('posts/video-posts/', accessToken);

    return response;
  }
}
