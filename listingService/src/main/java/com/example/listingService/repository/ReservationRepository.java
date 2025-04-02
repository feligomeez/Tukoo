package com.example.listingService.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.listingService.models.Reservation;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByListingIdAndStatus(Long listingId, String status);
    List<Reservation> findByListingId(Long listingId);
    List<Reservation> findByListingIdIn(List<Long> listingIds);
    List<Reservation> findAllByOrderByStartDateDesc();
    @Query("SELECT r FROM Reservation r WHERE r.listingId IN :listingIds")
    List<Reservation> findByListingIds(@Param("listingIds") List<Long> listingIds);
    List<Reservation> findByUserId(Long userId);
}
