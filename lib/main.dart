import 'package:blisso_mobile/screens/auth/matchingSelection_screen.dart';
import 'package:blisso_mobile/screens/auth/register_screen.dart';
import 'package:blisso_mobile/screens/splash/splash_screen.dart';
import 'package:blisso_mobile/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  final routes = RouteMap(routes: {
    '/': (_) => const MaterialPage(child: SplashScreen()),
    '/welcome': (_) => const MaterialPage(child: WelcomeScreen()),
    '/register': (_) => const MaterialPage(child: RegisterScreen()),
    '/matching-selection': (_) =>
        const MaterialPage(child: MatchingSelectionScreen())
  });

  runApp(MaterialApp.router(
    themeMode: ThemeMode.system,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    routerDelegate: RoutemasterDelegate(routesBuilder: (context) => routes),
    routeInformationParser: const RoutemasterParser(),
  ));
}
