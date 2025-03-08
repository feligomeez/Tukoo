package com.example.listingService.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.listingService.models.Reservation;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByListingIdAndStatus(Long listingId, String status);
    List<Reservation> findByListingId(Long listingId);
}
