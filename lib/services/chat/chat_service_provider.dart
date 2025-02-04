import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/chat/chat_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatServiceProvider extends StateNotifier<ApiState> {
  ChatServiceProvider(this.ref) : super(ApiState());

  final Ref ref;

  Future<void> getMessages() async {
    state = ApiState(isLoading: true);

    try {
      final chatService = ref.read(chatServiceProvider);
      final messages = await chatService.getAllMyMessages();

      if (!StatusCodes.codes.contains(messages.statusCode)) {
        state = ApiState(isLoading: false, error: messages.errorMessage);
      } else {
        try {
          state = ApiState(
              isLoading: false,
              data: messages.result,
              statusCode: messages.statusCode);
        } catch (e) {}
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }

  void addMessage(dynamic message) {
    List<Map<String, dynamic>> updatedChats =
        List.from(state.data); // Create a new list copy

    bool isUpdated = false;

    for (var chat in updatedChats) {
      if (chat.containsKey(message['receiver'])) {
        chat[message['receiver']] = List.from(chat[message['receiver']]!)
          ..add(message);
        isUpdated = true;
        break;
      }
    }

    if (!isUpdated) {
      updatedChats.add({
        message['receiver']: [message]
      });
    }

    state = ApiState(isLoading: false, data: updatedChats);
  }

  void addMessageFromListen(dynamic message) {
    print(message);
    List<Map<String, dynamic>> updatedChats =
        List.from(state.data); // Create a new list copy

    bool isUpdated = false;

    for (var chat in updatedChats) {
      if (chat.containsKey(message['sender'])) {
        chat[message['sender']] = List.from(chat[message['sender']]!)
          ..add(message);
        isUpdated = true;
        break;
      }
    }

    if (!isUpdated) {
      updatedChats.add({
        message['sender']: [message]
      });
    }

    state = ApiState(isLoading: false, data: updatedChats);
  }

  Future<List<dynamic>> getUserMessages(String username) async {
    if (state.data == null) {
      await getMessages();
    }

    for (var chat in state.data) {
      if (chat.containsKey(username)) {
        return chat[username];
      }
    }

    return [];
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final chatServiceProviderImpl =
    StateNotifierProvider<ChatServiceProvider, ApiState>(
  (ref) => ChatServiceProvider(ref),
);
