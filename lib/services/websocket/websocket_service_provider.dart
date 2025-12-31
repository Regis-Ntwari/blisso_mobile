import 'dart:convert';

import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/chat/typing_message_provider.dart';
import 'package:blisso_mobile/services/message_requests/message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/websocket/websocket_service.dart';
import 'package:blisso_mobile/utils/notification_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebSocketNotifier extends StateNotifier<String> {
  final WebSocketService _webSocketService;

  WebSocketNotifier(this._webSocketService, this.ref) : super('');

  final Ref ref;

  Future<void> connect() async {
    try {
      await _webSocketService.connect();
    } catch (e) {
      print(e.toString());
    }
  }

  void sendMessage(ChatMessageModel messageModel) {
    try {
      _webSocketService.sendMessage(messageModel);
      ref
          .read(chatServiceProviderImpl.notifier)
          .addMessage(messageModel.toMap());

      state = 'Sent: ${messageModel.toMap()}';
      debugPrint('Message sent');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void listenToMessages() async {
    _webSocketService.messageStream.listen((message) async {
      dynamic receivedMessage = jsonDecode(message);
      if (receivedMessage['action'] == 'typing') {
        ref.read(typingStatusProvider.notifier).updateTypingStatus(receivedMessage['sender'], true);
      } else {
        if (receivedMessage['action'] == 'edited') {
          String? username =
              await SharedPreferencesService.getPreference('username');
          ref.read(chatServiceProviderImpl.notifier).replaceMessageInChat(
              username == receivedMessage['sender']
                  ? receivedMessage['receiver']
                  : receivedMessage['sender'],
              receivedMessage);
        } else {
          ref
              .read(chatServiceProviderImpl.notifier)
              .addMessageFromListen(receivedMessage);
        }

        //final chatViewProvider = ref.read(getChatDetailsProviderImpl);

        // if(receivedMessage['sender'] == chatViewProvider['username']) {
        final chatViewUpdater = ref.read(getChatDetailsProviderImpl.notifier);
        if (receivedMessage['action'] == 'created') {
          chatViewUpdater.addMessageToChat(receivedMessage);
        } else if (receivedMessage['action'] == 'edited') {
          chatViewUpdater.replaceMessageInChat(receivedMessage);
        } else {
          chatViewUpdater.removeMessageFromChat(receivedMessage);
        }
        // }

        if (receivedMessage['action'] == 'created') {
          if (ref.read(messageRequestServiceProviderImpl).data == null) {
            await ref
                .read(messageRequestServiceProviderImpl.notifier)
                .mapApprovedUsers();
          }

          final users = ref.read(messageRequestServiceProviderImpl).data;

          NotificationComponent.showInAppNotification(
            title: users[receivedMessage['sender']]['fullname'],
            message: receivedMessage['content'] ?? 'You have a new message',
            avatarUrl: users[receivedMessage['sender']]['profile_picture_url'],
            onTap: () {
              // Navigate to the chat screen
              // You'll need to handle navigation based on your app structure
              // Example:

              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => ChatScreen(
              //       chatId: messageData['chatId'],
              //       userId: messageData['senderId'],
              //     ),
              //   ),
              // );
            },
          );
        }
      }
    });

    state = 'Received message ';
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final webSocketNotifierProvider =
    StateNotifierProvider<WebSocketNotifier, String>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return WebSocketNotifier(webSocketService, ref);
});
