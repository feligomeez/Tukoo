package com.example.listingService.models;

import java.time.LocalDateTime;


import jakarta.persistence.*;
import lombok.*;


@Entity
@Table(name = "listings")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Listing {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;
    private String category;
    
    @Column(nullable = false)
    private Double pricePerDay;

    @Column(nullable = false)
    @JoinColumn(name = "owner_id")
    private Long ownerId;

    private String location;

    @Column(nullable = false)
    private String status;//ACTIVE, EXPIRED

    @Column(nullable = false)
    private String createdAt;
    private String updatedAt;
}
