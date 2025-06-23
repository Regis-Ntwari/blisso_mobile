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

  void _applyMessageToChat(String chatKey, dynamic message) {
    List<Map<String, dynamic>> updatedChats = List.from(state.data ?? []);
    bool isUpdated = false;

    for (var chat in updatedChats) {
      if (chat['username'] == chatKey) {
        List messages = List.from(chat['messages']);
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
        chat['messages'] = messages;

        updatedChats.remove(chat);
        updatedChats.insert(0, chat);
        break;
      }
    }

    if (!isUpdated &&
        message['action'] != 'edited' &&
        message['action'] != 'deleted') {

      final newChat = {
        'username': message['receiver'],
        'full_name': '',
        'profile_picture_url': '',
        'nickname': '',
        'messages': [message]
      };
      updatedChats.insert(0, newChat);
    }

    state = ApiState(isLoading: false, data: updatedChats);
  }

  void addMessage(dynamic message) {
    _applyMessageToChat(message['receiver'], message);
  }

  void addMessageFromListen(dynamic message) {
    _applyMessageToChat(message['sender'], message);
  }

  Future<List<dynamic>> getUserMessages(String username) async {
    if (state.data == null) {
      await getMessages();
    }

    for (var chat in state.data) {
      if (chat['username'] == username) {
        return chat['messages'];
      }
    }

    return [];
  }

  void initializeChat(String username) {
    final currentState = state;
    List<Map<String, dynamic>> currentData = List.from(currentState.data ?? []);

    bool chatExists = false;
    for (var chat in currentData) {
      if (chat['username'] == username) {
        chatExists = true;
        break;
      }
    }

    if (!chatExists) {
      currentData.add({
        'username': username,
        'full_name': '',
        'profile_picture_url': '',
        'nickname': '',
        'messages': []
      });
      state = ApiState(data: currentData);
    }
  }

  void updateMessages(List<Map<String, dynamic>> messages) {
    state = ApiState(data: messages);
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final chatServiceProviderImpl =
    StateNotifierProvider<ChatServiceProvider, ApiState>(
  (ref) => ChatServiceProvider(ref),
);
