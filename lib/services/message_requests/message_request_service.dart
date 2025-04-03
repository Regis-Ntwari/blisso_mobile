import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class MessageRequestService {
  Future<ApiResponse> getApprovedUsers() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    String username = await SharedPreferencesService.getPreference('username');

    ApiResponse response =
        await ApiService().getData('users/$username', accessToken);

    return response;
  }
}
