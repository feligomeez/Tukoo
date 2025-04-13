import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/chat_conversation.dart';
import './chat.dart';
import './custom_bottom_nav.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final ChatService _chatService = ChatService();
  late Future<List<ChatConversation>> _conversationsFuture;
  String _searchQuery = ''; // Añadir variable para la búsqueda

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _chatService.getConversations();
  }

  // Método para filtrar las conversaciones
  List<ChatConversation> _filterConversations(List<ChatConversation> conversations) {
    if (_searchQuery.isEmpty) {
      return conversations;
    }
    return conversations.where((conversation) {
      final userName = "Usuario ${conversation.participant2Id}".toLowerCase();
      return userName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barra de búsqueda actualizada
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre de usuario...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          // Lista de conversaciones actualizada
          Expanded(
            child: FutureBuilder<List<ChatConversation>>(
              future: _conversationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tienes conversaciones'));
                } else {
                  final filteredConversations = _filterConversations(snapshot.data!);
                  
                  if (filteredConversations.isEmpty) {
                    return Center(
                      child: Text('No se encontraron conversaciones con "$_searchQuery"'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      return _buildConversationTile(context, conversation);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildConversationTile(BuildContext context, ChatConversation conversation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatView(
                userName: "Usuario ${conversation.participant2Id}",
                productName: "Producto ${conversation.listingId}",
                receiverId: conversation.participant2Id,
                listingId: conversation.listingId,
              ),
            ),
          );
        },
        leading: const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/profile_image.jpg'),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Usuario ${conversation.participant2Id}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              conversation.lastMessageTimestamp,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              conversation.lastMessageContent,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.phone_iphone,
                  size: 14,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  "Producto ${conversation.listingId}",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}