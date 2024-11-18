import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/models/profile_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class ProfileService {
  Future<ApiResponse> createProfile(ProfileModel profile) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');
    ApiResponse response = await ApiService().postFormDataRequest(
        endpoint: 'profiles/', body: profile.toMap(), token: accessToken);

    return response;
  }
}