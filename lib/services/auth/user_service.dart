import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

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
        endpoint: '/authentication/token/',
        body: {'username': username, 'password': password});

    return response;
  }

  Future<ApiResponse> generateLoginCode({bool sendLogin = true}) async {
    String? username;

    await SharedPreferencesService.getPreference("username").then((value) {
      username = value;
    });

    final response = await ApiService().postData(
        endpoint: '/authentication/generate-login-code/',
        body: {'username': username, 'send_login_code': sendLogin});

    return response;
  }

  Future<ApiResponse> loginViaBiometrics() async {
    ApiResponse response = await generateLoginCode(sendLogin: false);

    String password = response.result['password'];

    String? username;

    await SharedPreferencesService.getPreference("username").then((value) {
      username = value;
    });

    return loginUser(username!, password);
  }
}
