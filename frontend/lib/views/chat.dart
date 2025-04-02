import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'dart:async';

class ChatView extends StatefulWidget {
  final String userName;
  final String productName;
  final int receiverId;
  final int listingId;

  const ChatView({
    super.key,
    required this.userName,
    required this.productName,
    required this.receiverId,
    required this.listingId,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late Future<List<ChatMessage>> _messagesFuture = Future.value([]); // Inicialización predeterminada
  late int _userId; // Variable para almacenar el ID del usuario en sesión
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeUserIdAndLoadMessages();
    // Actualizar mensajes cada 5 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _refreshMessages();
      }
    });
  }

  Future<void> _initializeUserIdAndLoadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('user_id');

      if (userIdString == null) {
        throw Exception('No se encontró el ID del usuario en la sesión');
      }

      final userId = int.parse(userIdString);

      setState(() {
        _userId = userId;
        _messagesFuture = _chatService.getMessages(
          _userId,
          widget.receiverId,
          widget.listingId,
        );
      });

      // Para depuración
      _messagesFuture.then((messages) {
        print('Usuario actual: $_userId');
        print('Receptor: ${widget.receiverId}');
        print('Número de mensajes cargados: ${messages.length}');
        for (var message in messages) {
          print('Mensaje: ${message.content} - De: ${message.senderId} A: ${message.receiverId}');
        }
      });

    } catch (e) {
      setState(() {
        _messagesFuture = Future.error('Error al cargar los mensajes: $e');
      });
    }
  }

  void _refreshMessages() {
    if (mounted) {
      setState(() {
        _messagesFuture = _chatService.getMessages(
          _userId,
          widget.receiverId,
          widget.listingId,
        );
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              widget.productName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: FutureBuilder<List<ChatMessage>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Si no hay mensajes, muestra un contenedor vacío
                  return Container();
                } else {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: messages.length,
                    reverse: false,
                    itemBuilder: (context, index) {
                      return _buildMessage(messages[index]);
                    },
                  );
                }
              },
            ),
          ),
          // Campo de entrada de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isMe = message.senderId == _userId; // Compara con el ID del usuario en sesión
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? Colors.deepOrange : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message.timestamp,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () async {
                  if (_messageController.text.isNotEmpty) {
                    try {
                      // Imprimir para depuración
                      print('Enviando mensaje como usuario $_userId a usuario ${widget.receiverId}');
                      
                      await _chatService.sendMessage(
                        content: _messageController.text,
                        senderId: _userId,         // ID del usuario actual
                        receiverId: widget.receiverId, // ID del otro usuario
                        listingId: widget.listingId,
                      );

                      _messageController.clear();
                      _refreshMessages();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al enviar el mensaje: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}