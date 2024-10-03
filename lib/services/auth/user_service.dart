import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';

class UserService {
  Future<ApiResponse> registerUser(String username, String firstname,
      String lastname, String authType) async {
    final response = await ApiService()
        .postData(endpoint: '/authentication/sign-up/', body: {
      'username': username,
      'first_name': firstname,
      'last_name': lastname,
      'auth_type': authType
    });

    return response;
  }

  Future<ApiResponse> loginUser(String username, String password) async {
    final response = await ApiService().postData(
        endpoint: '/authentication/token',
        body: {'username': username, 'password': password});

    return response;
  }
}
