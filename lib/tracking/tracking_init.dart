import 'package:hive_flutter/hive_flutter.dart';
import 'tracking_event.dart';

Future<void> initTracking() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TrackingEventAdapter());
  await Hive.openBox<TrackingEvent>('tracking_events');
}
