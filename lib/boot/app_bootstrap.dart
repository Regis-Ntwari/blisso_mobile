import 'package:blisso_mobile/tracking/app_lifecycle_tracker.dart';
import 'package:flutter/material.dart';

class AppBootstrap extends StatefulWidget {
  final Widget child;

  const AppBootstrap({super.key, required this.child});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(AppLifecycleTracker());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
