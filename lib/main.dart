import 'package:blisso_mobile/l10n/l10n.dart';
import 'package:blisso_mobile/screens/auth/home_screen.dart';
import 'package:blisso_mobile/screens/auth/login_screen.dart';
import 'package:blisso_mobile/screens/auth/password_screen.dart';
import 'package:blisso_mobile/screens/home/homepage_screen.dart';
import 'package:blisso_mobile/screens/profile/matching_selection_screen.dart';
import 'package:blisso_mobile/screens/auth/register_screen.dart';
import 'package:blisso_mobile/screens/profile/profile_screen.dart';
import 'package:blisso_mobile/screens/profile/snapshots/profile_pictures_component.dart';
import 'package:blisso_mobile/screens/profile/snapshots/snapshot_screen.dart';
import 'package:blisso_mobile/screens/profile/snapshots/target_profile_snapshots_component.dart';
import 'package:blisso_mobile/screens/profile/subscription/subscription_screen.dart';
import 'package:blisso_mobile/screens/splash/splash_screen.dart';
import 'package:blisso_mobile/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  final routes = RouteMap(routes: {
    '/': (_) => const MaterialPage(child: SubscriptionScreen()),
    '/welcome': (_) => const MaterialPage(child: WelcomeScreen()),
    '/register/:type': (route) => MaterialPage(
        child: RegisterScreen(type: route.pathParameters['type']!)),
    '/matching-selection': (_) =>
        const MaterialPage(child: MatchingSelectionScreen()),
    '/Login': (_) => const MaterialPage(child: LoginScreen()),
    '/password': (_) => const MaterialPage(child: PasswordScreen()),
    '/home': (_) => const MaterialPage(child: HomeScreen()),
    '/homepage': (_) => const MaterialPage(child: HomepageScreen()),
    '/profile/': (_) => const MaterialPage(child: ProfileScreen()),
    '/snapshots': (_) => const MaterialPage(child: SnapshotScreen()),
    '/profile-pictures': (_) =>
        const MaterialPage(child: ProfilePicturesComponent()),
    '/target-snapshot': (_) =>
        const MaterialPage(child: TargetProfileSnapshotsComponent()),
  });

  runApp(ProviderScope(
    child: MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: L10n.allLocales,
      locale: const Locale('en'),
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      title: 'Blisso',
      darkTheme: ThemeData.dark(),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) => routes),
      routeInformationParser: const RoutemasterParser(),
    ),
  ));
}
