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
  late final Animation<AlignmentGeometry> _alignAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();

    _alignAnimation = Tween<AlignmentGeometry>(
            begin: Alignment.centerLeft, end: Alignment.centerRight)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.bounceIn));

    _rotationAnimation = Tween<double>(begin: 0, end: 2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.bounceIn));

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
    return SafeArea(
        child: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black54, Colors.black87])),
      child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/blisso.png'),
              SizedBox(
                height: 50,
                child: AlignTransition(
                    alignment: _alignAnimation,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                      ),
                    )),
              )
            ],
          )),
    ));
  }
}
