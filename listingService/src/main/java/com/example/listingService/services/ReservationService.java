package com.example.listingService.services;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.listingService.models.Listing;
import com.example.listingService.models.Reservation;
import com.example.listingService.repository.ReservationRepository;

@Service
public class ReservationService {
    @Autowired
    private ReservationRepository reservationRepository;

    @Autowired
    private ListingService listingService;

    public String createReservation(Reservation reservation) {
        // Validar fechas
        if (reservation.getStartDate().isAfter(reservation.getEndDate())) {
            return "Start date must be before end date.";
        }

        // Verificar disponibilidad
        List<Reservation> existingReservations = reservationRepository.findByListingIdAndStatus(reservation.getId(), "CONFIRMED");
        for (Reservation r : existingReservations) {
            if (!(reservation.getEndDate().isBefore(r.getStartDate()) || reservation.getStartDate().isAfter(r.getEndDate()))) {
                return "Listing is not available for the selected dates.";
            }
        }

        reservation.setStatus("PENDING");
        reservationRepository.save(reservation);
        return "Reservation created successfully.";
    }

    public String acceptReservation(Reservation reservation){
        reservation.setStatus("CONFIRMED");
        reservationRepository.save(reservation);
        return "Reservation accepted successfully.";
    }

    public String cancelReservation(Reservation reservation){
        reservation.setStatus("CANCELLED");
        reservationRepository.save(reservation);
        return "Reservation cancelled successfully.";
    }

    public List<Reservation> getReservationsByListing(Long listingId) {
        return reservationRepository.findByListingId(listingId);
    }

    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    public String updateReservationStatus(Long id, String newStatus) {
        // Validar que el estado sea válido
        List<String> validStatuses = Arrays.asList("CONFIRMED", "CANCELLED", "PENDING", "FINISHED", "REVIEWED", "IN_PROGRESS");
        if (!validStatuses.contains(newStatus.toUpperCase())) {
            return "Invalid status. Valid statuses are: CONFIRMED, CANCELLED, PENDING, FINISHED, REVIEWED, IN_PROGRESS.";
        }

        // Buscar la reserva
        Reservation reservation = reservationRepository.findById(id)
            .orElse(null);
        if (reservation == null) {
            return "Reservation not found";
        }

        // Actualizar el estado
        reservation.setStatus(newStatus.toUpperCase());
        reservationRepository.save(reservation);
        return "Reservation status updated to " + newStatus.toUpperCase();
    }

    public List<Reservation> getReservationsByOwnerId(Long ownerId) {
        try {
            // Get all listings owned by this user
            List<Listing> userListings = listingService.getListingsByOwnerId(ownerId);
            
            if (userListings.isEmpty()) {
                return new ArrayList<>();
            }
            List<Long> listingIds = userListings.stream()
                                              .map(Listing::getId)
                                              .collect(Collectors.toList());

            // Get all reservations for these listings
            return reservationRepository.findByListingIds(listingIds);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public List<Reservation> getReservationsByUserId(Long userId) {
        return reservationRepository.findByUserId(userId);
    }
}
