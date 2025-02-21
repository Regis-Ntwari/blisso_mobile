// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatMessageModel {
  String? messageId;
  final String action;
  final String sender;
  final String receiver;
  final String content;
  String? contentFileUrl;
  String? contentFileType;
  String? contentFile;
  bool isFileIncluded;
  String? senderReceiver;
  final String createdAt;
  String? parentId;
  String? parentContent;

  ChatMessageModel(
      {required this.sender,
      required this.receiver,
      required this.content,
      this.contentFileUrl,
      this.contentFileType,
      this.messageId,
      required this.isFileIncluded,
      required this.createdAt,
      required this.action,
      this.contentFile,
      this.parentId,
      this.parentContent,
      this.senderReceiver});

  ChatMessageModel copyWith(
      {String? sender,
      String? receiver,
      String? content,
      String? contentFileUrl,
      String? contentFileType,
      String? contentFile,
      bool? isFileIncluded,
      String? action,
      String? createdAt,
      String? messageId,
      String? parentId,
      String? senderReceiver,
      String? parentContent}) {
    return ChatMessageModel(
        sender: sender ?? this.sender,
        receiver: receiver ?? this.receiver,
        content: content ?? this.content,
        contentFileUrl: contentFileUrl ?? this.contentFileUrl,
        contentFile: contentFile ?? this.contentFile,
        contentFileType: contentFileType ?? this.contentFileType,
        isFileIncluded: isFileIncluded ?? this.isFileIncluded,
        createdAt: createdAt ?? this.createdAt,
        senderReceiver: senderReceiver ?? this.senderReceiver,
        action: action ?? this.action,
        parentId: parentId ?? this.parentId,
        messageId: messageId ?? this.messageId,
        parentContent: parentContent ?? this.parentContent);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message_id': messageId,
      'sender': sender,
      'receiver': receiver,
      'content': content,
      'content_file_url': contentFileUrl,
      'content_file_type': contentFileType,
      'is_file_included': isFileIncluded,
      'content_file': contentFile,
      'created_at': createdAt,
      'action': action,
      'parent_id': parentId,
      'parent_content': parentContent
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
        sender: map['sender'] as String,
        receiver: map['receiver'] as String,
        content: map['content'] as String,
        contentFileUrl: map['content_file_url'] != null
            ? map['content_file_url'] as String
            : '',
        contentFileType: map['content_file_type'] != null
            ? map['content_file_type'] as String
            : '',
        contentFile: map['content_file_type'] != null
            ? map['content_file_type'] as String
            : '',
        isFileIncluded: map['is_file_included'] as bool,
        createdAt: map['created_at'] as String,
        senderReceiver: map['sender_receiver'],
        action: map['action'],
        parentId: map['parent_id'],
        messageId: map['message_id'],
        parentContent: map['parent_content']);
  }

  String toJson() => json.encode(toMap());

  factory ChatMessageModel.fromJson(String source) =>
      ChatMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatMessageModel(sender: $sender, receiver: $receiver, contentFile: $contentFile content: $content, contentFileUrl: $contentFileUrl, contentFileType: $contentFileType, isFileIncluded: $isFileIncluded, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant ChatMessageModel other) {
    if (identical(this, other)) return true;

    return other.sender == sender &&
        other.receiver == receiver &&
        other.content == content &&
        other.messageId == messageId &&
        other.senderReceiver == senderReceiver &&
        other.contentFileUrl == contentFileUrl &&
        other.contentFileType == contentFileType &&
        other.isFileIncluded == isFileIncluded &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return sender.hashCode ^
        receiver.hashCode ^
        content.hashCode ^
        contentFileUrl.hashCode ^
        contentFileType.hashCode ^
        isFileIncluded.hashCode ^
        createdAt.hashCode;
  }
}
