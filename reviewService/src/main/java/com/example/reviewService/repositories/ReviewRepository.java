package com.example.reviewService.repositories;


import com.example.reviewService.models.Review;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByUserId(Long userId); // Buscar reviews por usuario
    List<Review> findByListingId(Long listingId); // Buscar reviews por producto
}
