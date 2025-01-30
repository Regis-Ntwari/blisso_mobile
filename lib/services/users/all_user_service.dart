import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class AllUserService {
  Future<ApiResponse> fetchAllUsers() async {
    String token = await SharedPreferencesService.getPreference('accessToken');
    final response =
        await ApiService().getData('authentication/users-map/', token);

    return response;
  }
}
