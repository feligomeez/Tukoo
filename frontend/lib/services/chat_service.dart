import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import 'dart:convert';

class ChatService {
  static const String _baseUrl = 'http://localhost:8080'; // HTTP base URL
  static const String _wsUrl = 'ws://localhost:8080'; // WebSocket base URL
  WebSocketChannel? _channel;
  final void Function(ChatMessage)? onMessageReceived;
  int? _currentUserId;

  ChatService({this.onMessageReceived}) {
    if (onMessageReceived != null) {
      _initializeWebSocket();
    }
  }

  Future<void> _initializeWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    _currentUserId = int.parse(prefs.getString('user_id') ?? '0');

    _channel = WebSocketChannel.connect(
      Uri.parse('$_wsUrl/ws/chat?token=$token'),
    );

    _channel?.stream.listen((message) {
      final data = json.decode(message);
      var chatMessage = ChatMessage.fromJson(data);
      chatMessage = chatMessage.copyWith(isMe: chatMessage.senderId == _currentUserId);
      onMessageReceived?.call(chatMessage);
    });
  }

  Future<List<ChatConversation>> getConversations(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/chat/conversations/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatConversation.fromJson(json)).toList();
    }
    throw Exception('Failed to load conversations');
  }

  Future<List<ChatMessage>> getMessageHistory(int receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userId = prefs.getString('user_id');

    if (token == null || userId == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/chat/history/$receiverId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> messages = json.decode(response.body);
      return messages.map((msg) {
        final chatMsg = ChatMessage.fromJson(msg);
        return chatMsg.copyWith(isMe: chatMsg.senderId == int.parse(userId));
      }).toList();
    }
    throw Exception('Failed to load message history');
  }

  Future<void> sendMessage(ChatMessage message) async {
    if (_channel == null) throw Exception('WebSocket not initialized');
    
    final messageJson = message.toJson();
    _channel?.sink.add(json.encode(messageJson));
  }

  void dispose() {
    _channel?.sink.close();
  }
}