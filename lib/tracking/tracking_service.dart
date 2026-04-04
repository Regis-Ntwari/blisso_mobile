import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'event_queue.dart';
import 'tracking_event.dart';

class TrackingService {
  TrackingService._();
  static final TrackingService instance = TrackingService._();

  final _uuid = const Uuid();
  String? _sessionId;
  String? _userId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('username') ?? 'anonymous';
  }

  void startSession() {
    if(_sessionId != null) return; // Session already started
    _sessionId = _uuid.v4();
    // track("session_start", {});
  }

  void endSession() {
    // track("session_end", {});
  }

  Future<void> track(String type, Map<String, dynamic> payload) async {
    if (_userId == null || _sessionId == null) return;

    final event = TrackingEvent(
      id: _uuid.v4(),
      type: type,
      timestamp: DateTime.now().toUtc(),
      payload: payload,
      userId: _userId!,
      sessionId: _sessionId!,
    );

    await EventQueue.instance.enqueue(event);
  }
}
