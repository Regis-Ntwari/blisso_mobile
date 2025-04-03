import 'package:blisso_mobile/screens/auth/home_screen.dart';
import 'package:blisso_mobile/screens/auth/login_screen.dart';
import 'package:blisso_mobile/screens/auth/password_screen.dart';
import 'package:blisso_mobile/screens/auth/profile/matching_selection_screen.dart';
import 'package:blisso_mobile/screens/auth/profile/profile_screen.dart';
import 'package:blisso_mobile/screens/auth/profile/snapshots/profile_pictures_component.dart';
import 'package:blisso_mobile/screens/auth/profile/snapshots/snapshot_screen.dart';
import 'package:blisso_mobile/screens/auth/profile/snapshots/target_profile_snapshots_component.dart';
import 'package:blisso_mobile/screens/auth/profile/subscription/subscription_screen.dart';
import 'package:blisso_mobile/screens/auth/profile/subscription/verification/webview_verification.dart';
import 'package:blisso_mobile/screens/auth/register_screen.dart';
import 'package:blisso_mobile/screens/chat/chat_screen.dart';
import 'package:blisso_mobile/screens/chat/chat_view_screen.dart';
import 'package:blisso_mobile/screens/home/components/profile/target_profile_component.dart';
import 'package:blisso_mobile/screens/home/components/stories/view_story_component.dart';
import 'package:blisso_mobile/screens/home/homepage_screen.dart';
import 'package:blisso_mobile/screens/my-profile/favorite_profile_screen.dart';
import 'package:blisso_mobile/screens/splash/splash_screen.dart';
import 'package:blisso_mobile/screens/utils/autowrite_screen.dart';
import 'package:blisso_mobile/screens/utils/video_player_screen.dart';
import 'package:blisso_mobile/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class Routing {
  static final routes = RouteMap(routes: {
    '/': (_) => const MaterialPage(child: SplashScreen()),
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
    '/subscription': (_) => const MaterialPage(child: SubscriptionScreen()),
    '/auto-write/:fulltext/:route': (route) => MaterialPage(
            child: AutowriteScreen(
          route.pathParameters['fulltext']!,
          null,
          route.pathParameters['route']!,
        )),
    '/target-profile': (route) =>
        const MaterialPage(child: TargetProfileComponent()),
    '/favorite-profile/:username': (route) => MaterialPage(
        child: FavoriteProfileScreen(
            profileUsername: route.pathParameters['username']!)),
    '/webview-complete/:url': (route) => MaterialPage(
        child: WebviewVerification(url: route.pathParameters['url']!)),
    '/chat': (_) => const MaterialPage(child: ChatScreen()),
    '/chat-detail/:username': (route) => MaterialPage(
            child: ChatViewScreen(
          username: route.pathParameters['username']!,
        )),
    '/chat-detail/:username/video-player': (route) => MaterialPage(
            child: VideoPlayerScreen(
          username: route.pathParameters['username'],
          videoUrl: route.queryParameters['videoUrl'],
          bytes: route.queryParameters['bytes'],
        )),
    '/homepage/view-story': (_) =>
        const MaterialPage(child: ViewStoryComponent()),
  });
}
