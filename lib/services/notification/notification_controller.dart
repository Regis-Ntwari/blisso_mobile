import 'package:blisso_mobile/routes/navigator_service.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:routemaster/routemaster.dart';

final notificationControllerProvider =
    Provider<NotificationController>((ref) {
  return NotificationController(ref);
});

class NotificationController {
  final Ref ref;
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationController(this.ref) {
    _init();
  }

  Future<void> _init() async {
    await _requestPermissions();
    await _initializeLocalNotifications();
    _listenFCMToken();
    _listenForegroundMessages();
    _listenNotificationClicks();
    _listenTerminatedMessages();
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          _navigateToChat(payload);
        }
      },
    );
  }

  void _listenFCMToken() async {
    final token = await _messaging.getToken();
    // save token to backend — not implemented here

    _messaging.onTokenRefresh.listen((token) {
      // update token to backend — not implemented
    });
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      final data = message.data;

      final sender = data['sender'];
      final action = data['action'];
      final chatKey = data['sender']; // from backend
      final currentUsername = sender;

      // Inject into chat state
      ref.read(chatServiceProviderImpl.notifier)
          .addMessageFromListen(data);

      // Don't show notification if user is already in same chat
      final currentRoute =
          Routemaster.of(NavigationService.context!).currentRoute.fullPath;

      if (currentRoute == '/chat/$currentUsername') {
        return;
      }

      // In-app banner
      showSimpleNotification(
        Text(message.notification?.title ?? sender),
        subtitle: Text(message.notification?.body ?? ""),
        background: Colors.blue,
      );

      // OS notification as well
      _showLocalNotification(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const android = AndroidNotificationDetails(
      'default_channel', 'Default',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? "New message",
      message.notification?.body ?? "",
      details,
      payload: message.data['sender'], // username to navigate to
    );
  }

  void _listenNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final username = message.data['sender'];
      _navigateToChat(username);
    });
  }

  void _listenTerminatedMessages() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      final username = message.data['sender'];
      _navigateToChat(username);
    }
  }

  void _navigateToChat(String username) {
    Routemaster.of(NavigationService.context!)
        .push('/chat/$username');
  }
}
