package com.example.listingService.repository;


import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.listingService.models.Listing;

public interface ListingRepository extends JpaRepository<Listing, Long> {
    List<Listing> findByStatus(String status);
    List<Listing> findByOwnerId(Long ownerId);
}
