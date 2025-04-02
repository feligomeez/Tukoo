package com.example.chatService.controllers;

import com.example.chatService.models.ChatConversation;
import com.example.chatService.models.ChatMessage;
import com.example.chatService.services.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/messages")
    public ResponseEntity<ChatMessage> sendMessage(
            @RequestBody ChatMessage message,
            @RequestParam Long listingId) {
        ChatMessage savedMessage = chatService.saveMessage(message, listingId);
        return ResponseEntity.ok(savedMessage);
    }

    @GetMapping("/messages")
    public ResponseEntity<List<ChatMessage>> getMessages(
            @RequestParam Long userId1,
            @RequestParam Long userId2,
            @RequestParam Long listingId) { 
        List<ChatMessage> messages = chatService.getMessagesBetweenUsersAndListing(userId1, userId2, listingId);
        return ResponseEntity.ok(messages);
    }

    @GetMapping("/conversations")
    public ResponseEntity<List<ChatConversation>> getConversations(@RequestParam Long userId) {
        List<ChatConversation> conversations = chatService.getConversationsForUser(userId);
        return ResponseEntity.ok(conversations);
    }
}