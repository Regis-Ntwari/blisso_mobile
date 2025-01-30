import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/chat/chat_service.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/users/all_user_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatServiceProvider extends StateNotifier<ApiState> {
  final ChatService chatService;
  final AllUserService allUserService;
  ChatServiceProvider(this.chatService, this.allUserService)
      : super(ApiState());

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
      final users = await allUserService.fetchAllUsers();
      final messages = await chatService.getAllMyMessages();

      if (!StatusCodes.codes.contains(messages.statusCode) ||
          !StatusCodes.codes.contains(users.statusCode)) {
        print(messages.errorMessage);
        print(users.errorMessage);
        state = ApiState(isLoading: false, error: messages.errorMessage);
      } else {
        print(users.result);
        print(messages.result);
        List<Map<String, List<dynamic>>> updatedMessages =
            messages.result.map((messageMap) {
          return messageMap.map((email, messageList) {
            String fullName = users.result[email]?["full_name"] ?? email;
            return MapEntry(fullName, messageList);
          });
        }).toList();
        state = ApiState(
            isLoading: false,
            data: updatedMessages,
            statusCode: messages.statusCode);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final chatServiceProviderImpl =
    StateNotifierProvider<ChatServiceProvider, ApiState>((ref) {
  return ChatServiceProvider(ChatService(), AllUserService());
});
