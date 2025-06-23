import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetChatDetailsProvider extends StateNotifier<Map<String, dynamic>> {
  GetChatDetailsProvider() : super({});

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

}

final getChatDetailsProviderImpl =
    StateNotifierProvider<GetChatDetailsProvider, Map<String, dynamic>>(
        (ref) => GetChatDetailsProvider());
