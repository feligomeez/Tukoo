package com.example.listingService.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;

import com.example.listingService.models.Reservation;
import com.example.listingService.services.ReservationService;

import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/reservations")
public class ReservationController {
    @Autowired
    private ReservationService reservationService;

    @PostMapping
    public ResponseEntity<String> createReservation(@RequestBody Reservation reservation){ 

        String response = reservationService.createReservation(reservation);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{listingId}")
    public ResponseEntity<List<Reservation>> getReservations(@PathVariable Long listingId) {
        List<Reservation> reservations = reservationService.getReservationsByListing(listingId);
        return ResponseEntity.ok(reservations);
    }

    @PutMapping("/{id}/confirm")
    public ResponseEntity<String> confirmReservation(@PathVariable Long id) {
        String response = reservationService.updateReservationStatus(id, "CONFIRMED");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<String> cancelReservation(@PathVariable Long id) {
        String response = reservationService.updateReservationStatus(id, "CANCELLED");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<String> updateReservationStatus(
            @PathVariable Long id,
            @RequestBody String status) {
        String response = reservationService.updateReservationStatus(id, status);
        return ResponseEntity.ok(response);
    }
}
