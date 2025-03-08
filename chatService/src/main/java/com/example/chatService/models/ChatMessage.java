package com.example.chatService.models;
import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long senderId;  // ID del usuario que envía el mensaje
    private Long receiverId; // ID del usuario que recibe el mensaje
    private Long listingId; // ID del listing (opcional si los chats son sobre un listing)
    private String content; // Contenido del mensaje

    private LocalDateTime timestamp = LocalDateTime.now();
}
