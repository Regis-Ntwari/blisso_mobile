import 'package:hive/hive.dart';

part 'tracking_event.g.dart';

@HiveType(typeId: 1)
class TrackingEvent extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  Map<String, dynamic> payload;

  @HiveField(4)
  String userId;

  @HiveField(5)
  String sessionId;

  TrackingEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.payload,
    required this.userId,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        //"id": id,
        "type": type,
        "activity_happened_at": timestamp.toIso8601String(),
        //"userId": userId,
        "session_id": sessionId,
        "from": payload['from'],
        "tab_from_departure_time": payload["tab_from_departure_time"], 
        "tab_from_arrival_time": payload["tab_from_arrival_time"],
        "to": payload["to"]
      };
}
