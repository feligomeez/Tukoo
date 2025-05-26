package com.example.listingService.models;

import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.Convert;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import org.hibernate.annotations.Type;


import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


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
    private Long ownerId;

    private String location;

    @Column(nullable = false)
    private String status;//ACTIVE, EXPIRED

    @Column(nullable = false)
    private String createdAt;
    private String updatedAt;

    @Column(columnDefinition = "jsonb")
    @Type(JsonType.class)
    private List<String> imageUrls;
}
