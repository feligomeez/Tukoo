package com.example.chatService.services;

import com.example.chatService.models.ChatMessage;
import com.example.chatService.repositories.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatMessageRepository chatMessageRepository;

    public List<ChatMessage> getMessagesBetweenUsers(String senderId, String receiverId) {
        return chatMessageRepository.findBySenderIdAndReceiverId(senderId, receiverId);
    }

    // Otros métodos...
}
