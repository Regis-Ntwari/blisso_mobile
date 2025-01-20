import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/chat/chat_service.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatServiceProvider extends StateNotifier<ApiState> {
  final ChatService chatService;
  ChatServiceProvider(this.chatService) : super(ApiState());

  Future<void> sendMessage(ChatMessageModel message) async {
    state = ApiState(isLoading: true);

    try {
      //final result = chatService.sendMessage(message);
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }

  Future<void> getMessages() async {
    state = ApiState(isLoading: true);

    try {
      String? username;

      await SharedPreferencesService.getPreference("username").then((value) {
        username = value;
      });
      final response = chatService.getMessages(username!);

      print(response);
      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        state = ApiState(isLoading: false, data: response.result);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final chatServiceProviderImpl =
    StateNotifierProvider<ChatServiceProvider, ApiState>((ref) {
  return ChatServiceProvider(ChatService());
});
