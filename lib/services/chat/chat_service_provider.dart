import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/chat/chat_service.dart';
import 'package:blisso_mobile/services/message_requests/message_request_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
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

  void _applyMessageToChat(String chatKey, dynamic message) async {
    List<Map<String, dynamic>> updatedChats = List.from(state.data ?? []);
    bool isUpdated = false;
    int index = -1;

    for (var chat in updatedChats) {
      index = index + 1;
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
        if (message['action'] == 'created') {
          updatedChats.insert(0, chat);
        } else {
          updatedChats.insert(index, chat);
        }
        break;
      }
    }

    if (!isUpdated &&
        message['action'] != 'edited' &&
        message['action'] != 'deleted') {
      if (ref.read(messageRequestServiceProviderImpl).data == null) {
        await ref
            .read(messageRequestServiceProviderImpl.notifier)
            .mapApprovedUsers();
      }

      final users = ref.read(messageRequestServiceProviderImpl).data;

      String username =
          await SharedPreferencesService.getPreference('username');

      String chatUser = username == message['receiver']
          ? message['sender']
          : message['receiver'];

      final newChat = {
        'username': chatUser,
        'full_name': users[chatUser]['fullname'],
        'profile_picture_url': users[chatUser]['profile_picture_url'],
        'nickname': users[chatUser]['nickname'],
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

  void initializeChat(String username) async {
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
      if (ref.read(messageRequestServiceProviderImpl).data == null) {
        await ref
            .read(messageRequestServiceProviderImpl.notifier)
            .mapApprovedUsers();
      }

      final users = ref.read(messageRequestServiceProviderImpl).data;

      String username =
          await SharedPreferencesService.getPreference('username');

      currentData.add({
        'username': username,
        'full_name': users[username]['fullname'],
        'profile_picture_url': users[username]['profile_picture_url'],
        'nickname': users[username]['nickname'],
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
