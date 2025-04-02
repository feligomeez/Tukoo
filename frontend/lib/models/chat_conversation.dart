import 'chat_message.dart';

class ChatConversation {
  final int id;
  final int participant1Id;
  final int participant2Id;
  final int listingId;
  final String lastMessageContent;
  final String lastMessageTimestamp;

  ChatConversation({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    required this.listingId,
    required this.lastMessageContent,
    required this.lastMessageTimestamp,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    // Manejar el caso en el que `lastMessage` sea null
    final lastMessage = json['lastMessage'];

    return ChatConversation(
      id: json['id'],
      participant1Id: json['participant1Id'],
      participant2Id: json['participant2Id'],
      listingId: json['listingId'],
      lastMessageContent: lastMessage != null ? lastMessage['content'] : 'Sin mensajes', // Valor predeterminado
      lastMessageTimestamp: lastMessage != null ? lastMessage['timestamp'] : '', // Valor predeterminado
    );
  }
}