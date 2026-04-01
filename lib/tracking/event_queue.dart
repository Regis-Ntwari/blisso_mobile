import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'tracking_event.dart';

class EventQueue {
  EventQueue._();
  static final EventQueue instance = EventQueue._();

  final _box = Hive.box<TrackingEvent>('tracking_events');

  dynamic loadVariables() async {
    final configData = await rootBundle.loadString('assets/config/config.json');

    final configs = jsonDecode(configData);

    return configs;
  }

  Future<void> enqueue(TrackingEvent event) async {
    await _box.put(event.id, event);
    _flush();
  }

  Future<void> _flush() async {
    if (_box.isEmpty) return;

    final batch = _box.values.take(25).toList();

    dynamic configs = await loadVariables();

    try {
      final body = jsonEncode(
          batch.map((e) {
            print(e);
            return e.toJson();
          }).toList(),
        );
        print("Flushing ${batch.length} events");
      print(body);
      final res = await http.post(
        Uri.parse(
            "${configs['BACKEND_URL']}/blisso_administration/mobile-user-activities/"),
        headers: {"Content-Type": "application/json"},
        body: body
      );

      print(res);

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
