import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/websocket/websocket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebSocketNotifier extends StateNotifier<String> {
  final WebSocketService _webSocketService;

  WebSocketNotifier(this._webSocketService) : super('');

  void connect() {
    _webSocketService.connect();
  }

  void sendMessage(ChatMessageModel messageModel) {
    _webSocketService.sendMessage(messageModel);
    state = 'Sent:';
  }

  void listenToMessages() {
    _webSocketService.messageStream.listen((message) {
      state = 'Received: $message';
    });
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
  return WebSocketNotifier(webSocketService);
});
