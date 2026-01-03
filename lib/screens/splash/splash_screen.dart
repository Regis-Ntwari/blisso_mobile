import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();

    navigateToRegister();
  }

  void navigateToRegister() async {
    Future.delayed(const Duration(seconds: 3));

    SharedPreferences prefs =
        await SharedPreferencesService.getSharedPreferences();

    prefs.containsKey("isRegistered")
        ? Routemaster.of(context).replace("/home")
        : Routemaster.of(context).replace('/welcome');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      body: SafeArea(
          child: Center(
              child: Image.asset(
        'assets/images/blisso.png',
        width: 200,
        height: 200,
      ))),
    );
  }
}
