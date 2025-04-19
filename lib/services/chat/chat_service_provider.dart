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
        } catch (e) {
          state = ApiState(isLoading: false, error: e.toString());
        }
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }

  void addMessage(dynamic message) {
    List<Map<String, dynamic>> updatedChats =
        List.from(state.data); // Copy list

    bool isUpdated = false;

    for (var chat in updatedChats) {
      if (chat.containsKey(message['receiver'])) {
        List messages = List.from(chat[message['receiver']]!);

        if (message['action'] == 'edited') {
          for (int i = 0; i < messages.length; i++) {
            if (messages[i]['message_id'] == message['message_id']) {
              messages[i] = message;
              isUpdated = true;
              break;
            }
          }
        } else if (message['action'] == 'deleted') {
          messages
              .removeWhere((msg) => msg['message_id'] == message['message_id']);
          isUpdated = true;
        } else {
          messages.add(message);
          isUpdated = true;
        }

        chat[message['receiver']] = messages;
        break;
      }
    }

    if (!isUpdated &&
        message['action'] != 'edited' &&
        message['action'] != 'deleted') {
      updatedChats.add({
        message['receiver']: [message]
      });
    }

    state = ApiState(isLoading: false, data: updatedChats);
  }

  void addMessageFromListen(dynamic message) {
    List<Map<String, dynamic>> updatedChats =
        List.from(state.data); // Copy list

    bool isUpdated = false;

    for (var chat in updatedChats) {
      if (chat.containsKey(message['sender'])) {
        List messages = List.from(chat[message['sender']]!);

        if (message['action'] == 'edited') {
          for (int i = 0; i < messages.length; i++) {
            if (messages[i]['message_id'] == message['message_id']) {
              messages[i] = message;
              isUpdated = true;
              break;
            }
          }
        } else if (message['action'] == 'deleted') {
          messages
              .removeWhere((msg) => msg['message_id'] == message['message_id']);
          isUpdated = true;
        } else {
          messages.add(message);
          isUpdated = true;
        }

        chat[message['sender']] = messages;
        break;
      }
    }

    if (!isUpdated &&
        message['action'] != 'edited' &&
        message['action'] != 'deleted') {
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
