import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetChatDetailsProvider extends StateNotifier<Map<String, dynamic>> {
  final Ref ref;
  GetChatDetailsProvider({required this.ref}) : super({});

  updateChatDetails(Map<String, dynamic> data) {
    state = data;
  }

  addMessageToChat(dynamic message) {
    final oldMessages = state['messages'] ?? [];
    state = {
      ...state,
      'messages': [...oldMessages, message],
    };
  }

  removeMessageFromChat(String id) {
    final oldMessages = state['messages'] ?? [];

    state = {
      ...state,
      'messages': oldMessages.where((msg) => msg['message_id'] != id).toList(),
    };
  }

  replaceMessageInChat(Map<String, dynamic> updatedMessage) {
    final oldMessages = state['messages'] ?? [];

    state = {
      ...state,
      'messages': oldMessages.map((msg) {
        if (msg['message_id'] == updatedMessage['message_id']) {
          return updatedMessage;
        }
        return msg;
      }).toList(),
    };
  }

  markMessagesAsSeen() async{
    final socket = ref.read(webSocketNotifierProvider.notifier);


    final oldMessages = state['messages'] ?? [];
    final newMessages = List<Map<String, dynamic>>.from(oldMessages);

    final username = await SharedPreferencesService.getPreference('username');


    for (int i = newMessages.length - 1; i >= 0; i--) {
      final msg = newMessages[i];

      if (msg['message_status'] == 'seen' && msg['sender'] == username) {
        break;
      }

      if ((msg['message_status'] == 'unseen' || msg['message_status'] == "") && msg['sender'] == username) {
        final updatedMsg = {
          ...msg,
          'action': 'edited',
          'message_status': 'seen',
        };

        print(updatedMsg);

        newMessages[i] = updatedMsg;

        // Send over socket
        //socket.sendSeenMessage(updatedMsg);
        socket.sendMessage(ChatMessageModel.fromMap(updatedMsg));
      }
    }

    state = {
      ...state,
      'messages': newMessages,
    };
  }
}

final getChatDetailsProviderImpl =
    StateNotifierProvider<GetChatDetailsProvider, Map<String, dynamic>>(
        (ref) => GetChatDetailsProvider(ref: ref));
