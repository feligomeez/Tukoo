package com.example.listingService.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;

import com.example.listingService.models.Reservation;
import com.example.listingService.services.ReservationService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/reservations")
@Tag(name = "Reservation", description = "Reservation management APIs")

public class ReservationController {
    @Autowired
    private ReservationService reservationService;

    @Operation(summary = "Create a new reservation")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Reservation created successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid input data"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "404", description = "Listing not found"),
        @ApiResponse(responseCode = "409", description = "Date conflict with existing reservation"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PostMapping
    public ResponseEntity<String> createReservation(@RequestBody Reservation reservation){ 
        String response = reservationService.createReservation(reservation);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Get reservations by owner ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Found reservations for owner"),
        @ApiResponse(responseCode = "204", description = "No reservations found"),
        @ApiResponse(responseCode = "404", description = "Owner not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @GetMapping("/owner/{ownerId}")
    public ResponseEntity<List<Reservation>> getReservationsByOwnerId(
        @Parameter(description = "ID of the owner") @PathVariable Long ownerId) {
        List<Reservation> reservations = reservationService.getReservationsByOwnerId(ownerId);
        return ResponseEntity.ok(reservations);
    }

    @Operation(summary = "Get reservations by listing ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Found reservations for listing"),
        @ApiResponse(responseCode = "204", description = "No reservations found"),
        @ApiResponse(responseCode = "404", description = "Listing not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @GetMapping("/{listingId}")
    public ResponseEntity<List<Reservation>> getReservations(
        @Parameter(description = "ID of the listing") @PathVariable Long listingId) {
        List<Reservation> reservations = reservationService.getReservationsByListing(listingId);
        return ResponseEntity.ok(reservations);
    }

    @Operation(summary = "Get reservations by user ID")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Reservation>> getReservationsByUserId(
        @Parameter(description = "ID of the user") @PathVariable Long userId) {
        List<Reservation> reservations = reservationService.getReservationsByUserId(userId);
        return ResponseEntity.ok(reservations);
    }

    @Operation(summary = "Get all reservations")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Found all reservations"),
        @ApiResponse(responseCode = "204", description = "No reservations found"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @GetMapping
    public ResponseEntity<List<Reservation>> getAllReservations() {
        List<Reservation> reservations = reservationService.getAllReservations();
        return ResponseEntity.ok(reservations);
    }

    @Operation(summary = "Confirm a reservation")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid status"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden"),
        @ApiResponse(responseCode = "404", description = "Reservation not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PutMapping("/{id}/confirm")
    public ResponseEntity<String> confirmReservation(
        @Parameter(description = "ID of the reservation") @PathVariable Long id) {
        String response = reservationService.updateReservationStatus(id, "CONFIRMED");
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Cancel a reservation")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid status"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden"),
        @ApiResponse(responseCode = "404", description = "Reservation not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PutMapping("/{id}/cancel")
    public ResponseEntity<String> cancelReservation(
        @Parameter(description = "ID of the reservation") @PathVariable Long id) {
        String response = reservationService.updateReservationStatus(id, "CANCELLED");
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Mark a reservation as finished")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid status"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden"),
        @ApiResponse(responseCode = "404", description = "Reservation not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PutMapping("/{id}/finish")
    public ResponseEntity<String> finishReservation(
        @Parameter(description = "ID of the reservation") @PathVariable Long id) {
        String response = reservationService.updateReservationStatus(id, "FINISHED");
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Mark a reservation as in progress")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid status"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden"),
        @ApiResponse(responseCode = "404", description = "Reservation not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PutMapping("/{id}/inprogress")
    public ResponseEntity<String> inProgressReservation(
        @Parameter(description = "ID of the reservation") @PathVariable Long id) {
        String response = reservationService.updateReservationStatus(id, "IN_PROGRESS");
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Mark a reservation as reviewed")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid status"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden"),
        @ApiResponse(responseCode = "404", description = "Reservation not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PutMapping("/{id}/review")
    public ResponseEntity<String> reviewReservation(
        @Parameter(description = "ID of the reservation") @PathVariable Long id) {
        String response = reservationService.updateReservationStatus(id, "REVIEWED");
        return ResponseEntity.ok(response);
    }

}
