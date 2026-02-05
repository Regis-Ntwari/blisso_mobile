import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'tracking_event.dart';

class EventQueue {
  EventQueue._();
  static final EventQueue instance = EventQueue._();

  final _box = Hive.box<TrackingEvent>('tracking_events');

  static const _endpoint =
      "https://api.yourdomain.com/events/batch";

  Future<void> enqueue(TrackingEvent event) async {
    await _box.put(event.id, event);
    _flush();
  }

  Future<void> _flush() async {
    if (_box.isEmpty) return;

    final batch = _box.values.take(25).toList();

    try {
      final res = await http.post(
        Uri.parse(_endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "events": batch.map((e) => e.toJson()).toList(),
        }),
      );

      if (res.statusCode == 200) {
        for (final e in batch) {
          await e.delete();
        }
      }
    } catch (_) {
      // silent retry later
    }
  }

  Future<void> flushAll() => _flush();
}
