// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackingEventAdapter extends TypeAdapter<TrackingEvent> {
  @override
  final int typeId = 1;

  @override
  TrackingEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingEvent(
      id: fields[0] as String,
      type: fields[1] as String,
      timestamp: fields[2] as DateTime,
      payload: (fields[3] as Map).cast<String, dynamic>(),
      userId: fields[4] as String,
      sessionId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.sessionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
