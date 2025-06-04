// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ShortStoryModel {
  final String id;
  final String username;
  final String nickname;
  final String profilePicture;
  final String videoUrl;
  final String description;
  final int likes;
  final List<dynamic> peopleLiked;
  final bool likedThisStory;

  ShortStoryModel({
    required this.id,
    required this.username,
    required this.nickname,
    required this.profilePicture,
    required this.videoUrl,
    required this.description,
    required this.likes,
    required this.peopleLiked,
    required this.likedThisStory,
  });

  ShortStoryModel copyWith({
    String? id,
    String? username,
    String? nickname,
    String? profilePicture,
    String? videoUrl,
    String? description,
    int? likes,
    List<dynamic>? peopleLiked,
    bool? likedThisStory,
  }) {
    return ShortStoryModel(
        id: id ?? this.id,
        username: username ?? this.username,
        nickname: nickname ?? this.nickname,
        profilePicture: profilePicture ?? this.profilePicture,
        videoUrl: videoUrl ?? this.videoUrl,
        description: description ?? this.description,
        likes: likes ?? this.likes,
        peopleLiked: peopleLiked ?? this.peopleLiked,
        likedThisStory: likedThisStory ?? this.likedThisStory);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'nickname': nickname,
      'profilePicture': profilePicture,
      'videoUrl': videoUrl,
      'description': description,
      'likes': likes,
      'peopleLiked': peopleLiked,
    };
  }

  factory ShortStoryModel.fromMap(Map<String, dynamic> map) {
    return ShortStoryModel(
        id: map['id'] as String,
        username: map['username'] as String,
        nickname: map['nickname'] as String,
        profilePicture: map['profile_picture'] as String,
        videoUrl: map['post_file_url'] as String,
        description: map['description'] as String,
        likes: map['likes'] as int? ?? 0,
        peopleLiked: map['people_liked'] as List<dynamic>,
        likedThisStory: map['liked_this_story'] as bool);
  }

  String toJson() => json.encode(toMap());

  factory ShortStoryModel.fromJson(String source) =>
      ShortStoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ShortStoryModel(id: $id, username: $username, nickname: $nickname, profilePicture: $profilePicture, videoUrl: $videoUrl, description: $description, likes: $likes, peopleLiked: $peopleLiked)';
  }

  @override
  bool operator ==(covariant ShortStoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.username == username &&
        other.nickname == nickname &&
        other.profilePicture == profilePicture &&
        other.videoUrl == videoUrl &&
        other.description == description &&
        other.likes == likes &&
        other.peopleLiked == peopleLiked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        nickname.hashCode ^
        profilePicture.hashCode ^
        videoUrl.hashCode ^
        description.hashCode ^
        likes.hashCode ^
        peopleLiked.hashCode;
  }
}
