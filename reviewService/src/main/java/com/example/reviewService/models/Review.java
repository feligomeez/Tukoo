package com.example.reviewService.models;

import lombok.*;
import jakarta.persistence.*;

@Entity
@Table(name = "reviews")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Review {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long userId;
    private String reviewerName;
    private Long listingId;
    private int rating; // Nota del 1 al 5
    private String comment;
}
