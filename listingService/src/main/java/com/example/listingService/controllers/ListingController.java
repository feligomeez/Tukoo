package com.example.listingService.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.listingService.models.Listing;
import com.example.listingService.services.ListingService;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequestMapping("/listing")
public class ListingController {
    @Autowired
    private ListingService listingService;

    @PostMapping
    public ResponseEntity<String> createListing(@RequestBody Listing listing) {
        String message = listingService.createListing(listing);
        return ResponseEntity.status(201).body(message);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Listing> getListing(@PathVariable Long id) {
        Listing center = listingService.getListingById(id);
        return ResponseEntity.ok(center);
    }

    @GetMapping
    public ResponseEntity<List<Listing>> getListings() {
        List<Listing> center = listingService.getListings();
        return ResponseEntity.ok(center);
    }

    @GetMapping("/owner/{ownerId}")
    public ResponseEntity<List<Listing>> getListingsByOwnerId(@PathVariable Long ownerId) {
        List<Listing> listings = listingService.getListingsByOwnerId(ownerId);
        return ResponseEntity.ok(listings);
    }

    @PatchMapping("/{id}")
    public ResponseEntity<String> updateListing(@PathVariable Long id, @RequestBody Listing user) {
        String message = listingService.updateListing(id, user);
        if (message.equals("Listing updated successfully.")) {
            return ResponseEntity.ok(message);
        }
        return ResponseEntity.status(401).body(message);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<String> updateStatus(@PathVariable Long id, @RequestBody String status) {
        String response = listingService.updateListingStatus(id, status);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteListing(@PathVariable Long id) {
        String message = listingService.deleteListing(id);
        return ResponseEntity.ok(message);
    }
}

