import 'dart:async';
import 'dart:convert';

import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnected = false;
  bool _disposed = false;
  
  // Queue for messages sent while offline
  final List<ChatMessageModel> _messageQueue = [];
  final int _maxQueueSize = 100; // Limit queue to prevent memory issues
  
  // Optional callback for connection state changes
  void Function(bool connected)? onConnectionChanged;
  
  // The main message stream that external code listens to
  final StreamController<dynamic> _messageController = StreamController<dynamic>();
  Stream<dynamic> get messageStream => _messageController.stream;
  
  Future<void> connect() async {
    if (_disposed) return;
    
    _cancelReconnectTimer();
    
    try {
      // Load config
      final configData = await rootBundle.loadString('assets/config/config.json');
      final configs = jsonDecode(configData);
      final websocketUrl = configs['CHAT_WEBSOCKET'];
      
      // Load username
      final username = await SharedPreferencesService.getPreference('username') ?? 'anonymous';
      
      // Close previous connection if exists
      _disconnect();
      
      // Create new connection
      _channel = IOWebSocketChannel.connect(websocketUrl);
      
      // Send authentication
      await _channel!.ready;
      _channel!.sink.add(username);
      
      // Listen to messages
      _subscription = _channel!.stream.listen(
        (message) {
          _reconnectAttempts = 0; // Reset attempts on successful message
          _messageController.add(message);
        },
        onDone: () => _handleDisconnection(),
        onError: (error) => _handleDisconnection(),
      );
      
      _isConnected = true;
      onConnectionChanged?.call(true);
      print('WebSocket connected');
      
      // Send any queued messages
      _sendQueuedMessages();
      
    } catch (error) {
      print('WebSocket connection error: $error');
      _scheduleReconnect();
    }
  }
  
  void sendMessage(ChatMessageModel message) {
    if (_isConnected && _channel != null) {
      try {
        _sendSingleMessage(message);
      } catch (e) {
        print('Failed to send message: $e');
        _queueMessage(message);
        _handleDisconnection();
      }
    } else {
      // Queue message and try to reconnect
      _queueMessage(message);
      if (!_isConnected) {
        _scheduleReconnect();
      }
    }
  }
  
  void _sendSingleMessage(ChatMessageModel message) {
    _channel!.sink.add(jsonEncode(message.toMap()));
  }
  
  void _queueMessage(ChatMessageModel message) {
    // Add to queue if there's space
    if (_messageQueue.length < _maxQueueSize) {
      _messageQueue.add(message);
      print('Message queued. Queue size: ${_messageQueue.length}');
    } else {
      print('Message queue full. Dropping oldest message.');
      _messageQueue.removeAt(0);
      _messageQueue.add(message);
    }
  }
  
  void _sendQueuedMessages() {
    if (_messageQueue.isEmpty) return;
    
    print('Sending ${_messageQueue.length} queued messages...');
    
    // Send messages one by one
    for (final message in _messageQueue.toList()) { // Copy list to avoid modification during iteration
      try {
        _sendSingleMessage(message);
        _messageQueue.remove(message); // Remove from queue after successful send
      } catch (e) {
        print('Failed to send queued message: $e');
        // Stop trying if one fails - connection might be lost again
        _handleDisconnection();
        break;
      }
    }
    
    print('Queue cleared. Remaining: ${_messageQueue.length}');
  }
  
  void _handleDisconnection() {
    if (_disposed) return;
    
    if (_isConnected) {
      _isConnected = false;
      onConnectionChanged?.call(false);
      print('WebSocket disconnected');
    }
    
    _scheduleReconnect();
  }
  
  void _scheduleReconnect() {
    if (_disposed) return;
    
    _cancelReconnectTimer();
    
    // Exponential backoff: 1, 2, 4, 8, 16, 30, 30, 30... seconds
    final delaySeconds = _reconnectAttempts < 5 
      ? Duration(seconds: 1 << _reconnectAttempts) // 2^attempts
      : Duration(seconds: 30);
    
    _reconnectAttempts++;
    print('Reconnecting in ${delaySeconds.inSeconds} seconds (attempt $_reconnectAttempts)');
    
    _reconnectTimer = Timer(delaySeconds, () {
      if (!_isConnected && !_disposed) {
        connect();
      }
    });
  }
  
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  void _disconnect() {
    _subscription?.cancel();
    _subscription = null;
    
    try {
      _channel?.sink.close();
    } catch (e) {
      // Ignore errors during close
    }
    
    _channel = null;
  }
  
  // Getter for queue size (optional, for UI)
  int get queueSize => _messageQueue.length;
  
  // Clear message queue (optional)
  void clearQueue() {
    _messageQueue.clear();
    print('Message queue cleared');
  }
  
  void dispose() {
    _disposed = true;
    _cancelReconnectTimer();
    _disconnect();
    _messageController.close();
    print('WebSocket service disposed');
  }
}