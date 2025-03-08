package com.example.chatService.repositories;

import com.example.chatService.models.ChatConversation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChatConversationRepository extends JpaRepository<ChatConversation, Long>{
    List<ChatConversation> findByUser1IdOrUser2Id(Long userId1, Long userId2);
}
