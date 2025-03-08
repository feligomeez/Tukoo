package com.example.chatService.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.*;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import com.example.chatService.models.ChatMessage;
import com.example.chatService.services.ChatService;

@Controller
public class ChatController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private ChatService chatService;

    @MessageMapping("/chat.sendMessage")
    @SendTo("/topic/messages")
    public ChatMessage sendMessage(ChatMessage message) {
        ChatMessage savedMessage = chatService.saveMessage(message);
        return savedMessage;
    }

    @MessageMapping("/chat.privateMessage")
    public void sendPrivateMessage(@Payload ChatMessage message) {
        ChatMessage savedMessage = chatService.saveMessage(message);
        messagingTemplate.convertAndSendToUser(
                message.getReceiverId().toString(), "/queue/messages", savedMessage);
    }
}