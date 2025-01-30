import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class ChatService {
  Future<ApiResponse> sendMessage(ChatMessageModel message) async {
    return await ApiService().getData('endpoint', 'token');
  }

  Future<ApiResponse> getAllMyMessages() async {
    String token = await SharedPreferencesService.getPreference('accessToken');
    String username = await SharedPreferencesService.getPreference('username');
    final response =
        await ApiService().getData('messages/$username', token, isChat: true);

    return response;
  }
}
