import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class MessageRequestService {
  Future<ApiResponse> getApprovedUsers() async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    String username = await SharedPreferencesService.getPreference('username');

    ApiResponse response = await ApiService()
        .getData('users/$username', accessToken, isChat: true);

    return response;
  }

  Future<ApiResponse> sendMessageRequest(String receiverUsername) async {
    String username = await SharedPreferencesService.getPreference('username');

    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postData(
        endpoint: 'matching/message-requests/CONNECTION/',
        token: accessToken,
        body: {
          'requester_profile_email': username,
          'target_profile_email': receiverUsername
        });

    return response;
  }

  Future<ApiResponse> getMessageRequests() async {
    String username = await SharedPreferencesService.getPreference('username');

    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService()
        .getData('matching/message-requests/user/$username', accessToken);

    return response;
  }

  Future<ApiResponse> acceptMessageRequest(int id) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postData(
        endpoint: 'matching/message-requests/ACCEPTED/$id',
        body: {},
        token: accessToken);

    return response;
  }

  Future<ApiResponse> rejectMessageRequest(int id) async {
    String accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    ApiResponse response = await ApiService().postData(
        endpoint: 'matching/message-requests/REJECTED/$id',
        body: {},
        token: accessToken);

    return response;
  }
}
