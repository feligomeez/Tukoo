import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ChatMessage {
  final int? id;
  final int senderId;
  final int receiverId;
  final int? listingId;
  final String content;
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.receiverId,
    this.listingId,
    required this.content,
    required this.timestamp,
    this.isMe = false,
  });

  ChatMessage copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    int? listingId,
    String? content,
    DateTime? timestamp,
    bool? isMe,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      listingId: listingId ?? this.listingId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as int?,
    senderId: json['senderId'] as int,
    receiverId: json['receiverId'] as int,
    listingId: json['listingId'] as int?,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isMe: false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'listingId': listingId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  String get text => content;
  String get time => _formatTime(timestamp);

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}