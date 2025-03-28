package com.example.listingService.repository;

import com.example.listingService.models.ListingImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ListingImageRepository extends JpaRepository<ListingImage, Long> {
    List<ListingImage> findByListingId(Long listingId);
}