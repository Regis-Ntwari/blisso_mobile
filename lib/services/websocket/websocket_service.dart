import 'dart:convert';

import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  late WebSocketChannel _channel;

  void connect() async {
    final configData = await rootBundle.loadString('assets/config/config.json');

    final configs = jsonDecode(configData);
    _channel = IOWebSocketChannel.connect(configs['CHAT_WEBSOCKET']);
  }

  void sendMessage(ChatMessageModel message) {
    _channel.sink.add(message.toMap());
  }

  Stream<dynamic> get messageStream => _channel.stream;

  void dispose() {
    _channel.sink.close();
  }
}
