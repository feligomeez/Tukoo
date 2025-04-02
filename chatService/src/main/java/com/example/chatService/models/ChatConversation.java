package com.example.chatService.models;

import com.fasterxml.jackson.annotation.JsonManagedReference;
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

    private Long participant1Id;
    private Long participant2Id;

    private Long listingId; // Asociar la conversación a un producto

    @OneToMany(
        mappedBy = "conversation",
        cascade = CascadeType.ALL,
        orphanRemoval = true
    )
    @JsonManagedReference // Evita la serialización infinita
    private List<ChatMessage> messages = new ArrayList<>();

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    @JoinColumn(name = "last_message_id")
    private ChatMessage lastMessage;

    public void addMessage(ChatMessage message) {
        messages.add(message);
        message.setConversation(this);
        this.lastMessage = message; // Actualiza el último mensaje
    }

    public void removeMessage(ChatMessage message) {
        messages.remove(message);
        message.setConversation(null);

        // Si el mensaje eliminado es el último mensaje, actualiza el campo lastMessage
        if (message.equals(this.lastMessage)) {
            this.lastMessage = messages.isEmpty() ? null : messages.get(messages.size() - 1);
        }
    }

    public boolean involvesParticipant(Long participantId) {
        return participant1Id.equals(participantId) || participant2Id.equals(participantId);
    }
}
