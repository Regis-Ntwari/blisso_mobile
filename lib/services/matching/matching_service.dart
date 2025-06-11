import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class MatchingService {
  Future<ApiResponse> getMatchingRecommendations() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService()
        .getData('/matching/user-matching-scores/', accessToken);

    return response;
  }
}
