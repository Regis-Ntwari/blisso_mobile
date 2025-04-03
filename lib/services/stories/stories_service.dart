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

    ApiResponse response =
        await ApiService().getData('posts/stories/', accessToken);

    return response;
  }
}
