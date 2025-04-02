package com.example.chatService.services;

import com.example.chatService.models.ChatConversation;
import com.example.chatService.models.ChatMessage;
import com.example.chatService.repositories.ChatConversationRepository;
import com.example.chatService.repositories.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final ChatConversationRepository chatConversationRepository;

    public ChatMessage saveMessage(ChatMessage message, Long listingId) {
        // Establece la fecha y hora actual
        message.setTimestamp(LocalDateTime.now());

        // Encuentra o crea una conversación
        ChatConversation conversation = findOrCreateConversation(message.getSenderId(), message.getReceiverId(), listingId);
        message.setConversation(conversation);

        // Guarda el mensaje
        return chatMessageRepository.save(message);
    }

    public List<ChatMessage> getMessagesBetweenUsers(Long senderId, Long receiverId) {
        Optional<ChatConversation> conversation = chatConversationRepository.findByParticipant1IdOrParticipant2Id(senderId, receiverId)
                .stream()
                .filter(c -> c.involvesParticipant(senderId) && c.involvesParticipant(receiverId))
                .findFirst();

        return conversation.map(ChatConversation::getMessages).orElse(List.of());
    }

    public List<ChatMessage> getMessagesBetweenUsersAndListing(Long userId1, Long userId2, Long listingId) {
        // Busca una conversación que coincida con los participantes y el listingId
        Optional<ChatConversation> conversation = chatConversationRepository
                .findByUsersAndListing(listingId, userId1, userId2)
                .stream()
                .findFirst();

        // Devuelve los mensajes de la conversación encontrada o una lista vacía si no existe
        return conversation.map(ChatConversation::getMessages).orElse(List.of());
    }

    public List<ChatConversation> getConversationsForUser(Long userId) {
        return chatConversationRepository.findByParticipant1IdOrParticipant2Id(userId, userId);
    }

    private ChatConversation findOrCreateConversation(Long participant1Id, Long participant2Id, Long listingId) {
        // Validar que los participantes no sean el mismo usuario
        if (participant1Id.equals(participant2Id)) {
            throw new IllegalArgumentException("Los participantes no pueden ser el mismo usuario.");
        }

        // Busca una conversación que coincida con los participantes y el listingId
        return chatConversationRepository.findByParticipant1IdOrParticipant2Id(participant1Id, participant2Id)
                .stream()
                .filter(c -> 
                    ((c.getParticipant1Id().equals(participant1Id) && c.getParticipant2Id().equals(participant2Id)) ||
                     (c.getParticipant1Id().equals(participant2Id) && c.getParticipant2Id().equals(participant1Id))) &&
                     c.getListingId().equals(listingId))
                .findFirst()
                .orElseGet(() -> {
                    // Si no existe, crea una nueva conversación
                    ChatConversation newConversation = ChatConversation.builder()
                            .participant1Id(participant1Id)
                            .participant2Id(participant2Id)
                            .listingId(listingId)
                            .build();
                    return chatConversationRepository.save(newConversation);
                });
    }
}
