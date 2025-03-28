package com.example.chatService.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class ChatConversation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String participant1Id;
    private String participant2Id;

    @OneToMany(
        mappedBy = "conversation",
        cascade = CascadeType.ALL,
        orphanRemoval = true
    )
    private List<ChatMessage> messages = new ArrayList<>();

    public void addMessage(ChatMessage message) {
        messages.add(message);
        message.setConversation(this);
    }

    public void removeMessage(ChatMessage message) {
        messages.remove(message);
        message.setConversation(null);
    }
}
