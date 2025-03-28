package com.example.listingService.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "listing_images")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ListingImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String imageUrl;

    @ManyToOne
    @JoinColumn(name = "listing_id", nullable = false)
    private Listing listing;
}