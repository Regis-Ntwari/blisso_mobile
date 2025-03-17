// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ShortStoryModel {
  final String id;
  final String username;
  final String videoUrl;
  final String description;

  ShortStoryModel({
    required this.id,
    required this.username,
    required this.videoUrl,
    required this.description,
  });

  ShortStoryModel copyWith({
    String? id,
    String? username,
    String? videoUrl,
    String? description,
  }) {
    return ShortStoryModel(
      id: id ?? this.id,
      username: username ?? this.username,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'videoUrl': videoUrl,
      'description': description,
    };
  }

  factory ShortStoryModel.fromMap(Map<String, dynamic> map) {
    return ShortStoryModel(
      id: map['id'] as String,
      username: map['username'] as String,
      videoUrl: map['videoUrl'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShortStoryModel.fromJson(String source) =>
      ShortStoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ShortStoryModel(id: $id, username: $username, videoUrl: $videoUrl, description: $description)';
  }

  @override
  bool operator ==(covariant ShortStoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.username == username &&
        other.videoUrl == videoUrl &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        videoUrl.hashCode ^
        description.hashCode;
  }
}
