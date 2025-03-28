class ChatConversation {
  final int id;
  final int user1Id;
  final int user2Id;
  final int? listingId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? productName;
  final String? productImage;

  ChatConversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.listingId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.productName,
    this.productImage,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as int,
      user1Id: json['user1Id'] as int,
      user2Id: json['user2Id'] as int,
      listingId: json['listingId'] as int?,
      otherUserName: json['otherUserName'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      productName: json['productName'] as String?,
      productImage: json['productImage'] as String?,
    );
  }
}