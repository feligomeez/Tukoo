package com.example.chatService.repositories;

import com.example.chatService.models.ChatConversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatConversationRepository extends JpaRepository<ChatConversation, Long> {
    List<ChatConversation> findByParticipant1IdOrParticipant2Id(Long participant1Id, Long participant2Id);

    List<ChatConversation> findByListingId(Long listingId); // Buscar por producto

    @Query("SELECT c FROM ChatConversation c " +
           "WHERE c.listingId = :listingId " +
           "AND ((c.participant1Id = :userId1 AND c.participant2Id = :userId2) " +
           "OR (c.participant1Id = :userId2 AND c.participant2Id = :userId1))")
    List<ChatConversation> findByUsersAndListing(
            @Param("listingId") Long listingId,
            @Param("userId1") Long userId1,
            @Param("userId2") Long userId2);
}
