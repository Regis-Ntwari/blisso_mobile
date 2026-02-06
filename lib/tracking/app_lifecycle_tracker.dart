import 'package:flutter/widgets.dart';
import 'tracking_service.dart';
import 'event_queue.dart';

class AppLifecycleTracker with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        TrackingService.instance.startSession();
        TrackingService.instance.track("app_opened", {});
        EventQueue.instance.flushAll();
        break;

      case AppLifecycleState.paused:
        TrackingService.instance.track("app_backgrounded", {});
        TrackingService.instance.endSession();
        break;

      case AppLifecycleState.detached:
        TrackingService.instance.track("app_terminated", {});
        debugPrint("App detached");
        break;

      default:
        break;
    }
  }
}
