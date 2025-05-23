import 'dart:convert';

import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/websocket/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebSocketNotifier extends StateNotifier<String> {
  final WebSocketService _webSocketService;

  WebSocketNotifier(this._webSocketService, this.ref) : super('');

  final Ref ref;

  Future<void> connect() async {
    await _webSocketService.connect();
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

  void listenToMessages() {
    _webSocketService.messageStream.listen((message) {
      ref
          .read(chatServiceProviderImpl.notifier)
          .addMessageFromListen(jsonDecode(message));
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
