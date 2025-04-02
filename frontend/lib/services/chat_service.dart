import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import 'dart:convert';

class ChatService {
  static const String _baseUrl = 'http://192.168.1.136:8084/api/chat';

  /// Obtiene las conversaciones del usuario en sesión
  Future<List<ChatConversation>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final token = prefs.getString('jwt_token');

    if (userId == null || token == null) {
      throw Exception('User ID or token not found in session');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/conversations?userId=$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((json) => ChatConversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  /// Obtiene el historial de mensajes entre el usuario en sesión y otro usuario
  Future<List<ChatMessage>> getMessageHistory(int receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final token = prefs.getString('jwt_token');

    if (userId == null || token == null) {
      throw Exception('User ID or token not found in session');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/messages?senderId=$userId&receiverId=$receiverId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messages = json.decode(utf8.decode(response.bodyBytes));
      return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
    } else {
      throw Exception('Failed to load message history');
    }
  }

  /// Recupera los mensajes de una conversación
  Future<List<ChatMessage>> getMessages(int userId1, int userId2, int listingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Token not found in session');
    }

    // Asegurarse de que el orden de los IDs de usuario sea consistente
    final minUserId = userId1 < userId2 ? userId1 : userId2;
    final maxUserId = userId1 < userId2 ? userId2 : userId1;

    final response = await http.get(
      Uri.parse('$_baseUrl/messages?userId1=$minUserId&userId2=$maxUserId&listingId=$listingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messages = json.decode(utf8.decode(response.bodyBytes));
      print('Mensajes recibidos: $messages'); // Para depuración
      return messages.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  /// Envía un mensaje
  Future<ChatMessage> sendMessage({
    required String content,
    required int senderId,    // ID del usuario que envía (usuario actual)
    required int receiverId,  // ID del otro usuario en la conversación
    required int listingId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) {
      throw Exception('Token not found in session');
    }

    // Agregar log para depuración
    print('Enviando mensaje - De: $senderId A: $receiverId');

    final response = await http.post(
      Uri.parse('$_baseUrl/messages?listingId=$listingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'content': content,
        'senderId': senderId,     // Asegurarse de que este sea el ID del usuario actual
        'receiverId': receiverId, // Asegurarse de que este sea el ID del otro usuario
      }),
    );

    if (response.statusCode == 200) {
      final message = ChatMessage.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      // Verificar que los IDs se asignaron correctamente
      print('Mensaje enviado - De: ${message.senderId} A: ${message.receiverId}');
      return message;
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
}