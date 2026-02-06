import 'package:blisso_mobile/boot/app_bootstrap.dart';
import 'package:blisso_mobile/l10n/l10n.dart';
import 'package:blisso_mobile/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:routemaster/routemaster.dart';

import 'l10n/app_localizations.dart';

import 'tracking/tracking_init.dart';
import 'tracking/tracking_service.dart';
import 'tracking/app_lifecycle_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initTracking();

  await TrackingService.instance.init();

  WidgetsBinding.instance.addObserver(AppLifecycleTracker());

  runApp(
    AppBootstrap(
      child: ProviderScope(
        child: OverlaySupport.global(
          child: MaterialApp.router(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.allLocales,
            locale: const Locale('en'),
            themeMode: ThemeMode.system,
            theme: ThemeData.light(),
            title: 'Blisso',
            darkTheme: ThemeData.dark(),
            routerDelegate:
                RoutemasterDelegate(routesBuilder: (context) => Routing.routes),
            routeInformationParser: const RoutemasterParser(),
          ),
        ),
      ),
    ),
  );
}
