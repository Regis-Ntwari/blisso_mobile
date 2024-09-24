import 'package:blisso_mobile/screens/auth/login_screen.dart';
import 'package:blisso_mobile/screens/auth/password_screen.dart';
import 'package:blisso_mobile/screens/profile/matchingSelection_screen.dart';
import 'package:blisso_mobile/screens/auth/register_screen.dart';
import 'package:blisso_mobile/screens/splash/splash_screen.dart';
import 'package:blisso_mobile/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  final routes = RouteMap(routes: {
    '/': (_) => const MaterialPage(child: SplashScreen()),
    '/welcome': (_) => const MaterialPage(child: WelcomeScreen()),
    '/register/:type': (route) => MaterialPage(
        child: RegisterScreen(type: route.pathParameters['type']!)),
    '/matching-selection': (_) =>
        const MaterialPage(child: MatchingSelectionScreen()),
    '/Login': (_) => const MaterialPage(child: LoginScreen()),
    '/password/:username': (route) => MaterialPage(
            child: PasswordScreen(
          username: route.pathParameters['username']!,
        ))
  });

  runApp(MaterialApp.router(
    themeMode: ThemeMode.system,
    theme: ThemeData.light(),
    title: 'Blisso',
    darkTheme: ThemeData.dark(),
    routerDelegate: RoutemasterDelegate(routesBuilder: (context) => routes),
    routeInformationParser: const RoutemasterParser(),
  ));
}
