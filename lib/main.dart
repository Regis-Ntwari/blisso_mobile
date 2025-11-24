import 'package:blisso_mobile/l10n/l10n.dart';
import 'package:blisso_mobile/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'l10n/app_localizations.dart';

/// HANDLE BACKGROUND MESSAGES
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle storing message or updating local storage here if needed.
  // Avoid navigation here (can't navigate).
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase (required for FCM)
  await Firebase.initializeApp();

  /// Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// Ask for notification permissions (iOS + Android 13+)
  await FirebaseMessaging.instance.requestPermission();

  runApp(
    const ProviderScope(
      child: BlissoApp(),
    ),
  );
}

class BlissoApp extends StatefulWidget {
  const BlissoApp({super.key});

  @override
  State<BlissoApp> createState() => _BlissoAppState();
}

class _BlissoAppState extends State<BlissoApp> {
  final _routerDelegate =
      RoutemasterDelegate(routesBuilder: (context) => Routing.routes);

  @override
  void initState() {
    super.initState();

    /// LISTEN FOR NOTIFICATION TAPS (terminated + background)
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessageNavigation);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

    /// FOREGROUND NOTIFICATIONS → show banner or snackbar
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
  }

  /// 🔥 Handle notification → navigate to chat
  void _handleMessageNavigation(RemoteMessage? message) {
    if (message == null) return;

    final chatId = message.data['username']; // your backend will send this
    if (chatId != null) {
      _routerDelegate.replace('/chat/$chatId');
    }
  }

  /// 🔥 Handle foreground notification (in-app)
  void _handleForegroundNotification(RemoteMessage message) {
    // Here you show a custom banner / overlay (not OS-level)
    // Example basic snackbar:
    if (mounted) {
      final notification = message.notification;
      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notification.title ?? 'Message received')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: const RoutemasterParser(),
      title: 'Blisso',

      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      supportedLocales: L10n.allLocales,
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
    );
  }
}
