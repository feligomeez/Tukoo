package com.example.listingService.controllers;

import java.util.List;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.MediaType;

import com.example.listingService.config.CloudStorageService;
import com.example.listingService.models.Listing;
import com.example.listingService.services.ListingService;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/listing")
@Tag(name = "Listing", description = "Listing management APIs")
public class ListingController {
    @Autowired
    private ListingService listingService;

    @Autowired
    private CloudStorageService cloudStorageService;

    @Operation(summary = "Create a new listing")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Listing created successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid input data"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PostMapping
    public ResponseEntity<Map<String, Object>> createListing(@RequestBody Listing listing) {
        Map<String, Object> response = new HashMap<>();
        try {
            Listing createdListing = listingService.createListing(listing);
            response.put("id", createdListing.getId());
            return ResponseEntity.status(201).body(response);
        } catch (Exception e) {
            response.put("message", "Failed to create listing");
            response.put("error", e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    @Operation(summary = "Get a listing by its ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Listing found"),
        @ApiResponse(responseCode = "404", description = "Listing not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @GetMapping("/{id}")
    public ResponseEntity<Listing> getListing(
        @Parameter(description = "ID of the listing to be obtained") @PathVariable Long id) {
        Listing center = listingService.getListingById(id);
        return ResponseEntity.ok(center);
    }

    @Operation(summary = "Get all listings")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Found all listings"),
        @ApiResponse(responseCode = "204", description = "No listings found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @GetMapping
    public ResponseEntity<List<Listing>> getListings() {
        List<Listing> center = listingService.getListings();
        return ResponseEntity.ok(center);
    }

    @Operation(summary = "Get listings by owner ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Found listings for owner"),
        @ApiResponse(responseCode = "204", description = "No listings found for owner"),
        @ApiResponse(responseCode = "404", description = "Owner not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @GetMapping("/owner/{ownerId}")
    public ResponseEntity<List<Listing>> getListingsByOwnerId(
        @Parameter(description = "ID of the owner") @PathVariable Long ownerId) {
        List<Listing> listings = listingService.getListingsByOwnerId(ownerId);
        return ResponseEntity.ok(listings);
    }

    @Operation(summary = "Update a listing")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Listing updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid input data"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden"),
        @ApiResponse(responseCode = "404", description = "Listing not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PatchMapping("/{id}")
    public ResponseEntity<String> updateListing(
        @Parameter(description = "ID of the listing to update") @PathVariable Long id,
        @RequestBody Listing user) {
        String message = listingService.updateListing(id, user);
        if (message.equals("Listing updated successfully.")) {
            return ResponseEntity.ok(message);
        }
        return ResponseEntity.status(401).body(message);
    }

    @Operation(summary = "Update listing status")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Status updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid status"),
        @ApiResponse(responseCode = "404", description = "Listing not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PutMapping("/{id}/status")
    public ResponseEntity<String> updateStatus(@PathVariable Long id, @RequestBody String status) {
        String response = listingService.updateListingStatus(id, status);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Delete a listing")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Listing deleted successfully"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden"),
        @ApiResponse(responseCode = "404", description = "Listing not found"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteListing(@PathVariable Long id) {
        String message = listingService.deleteListing(id);
        return ResponseEntity.ok(message);
    }

    @Operation(summary = "Upload images for a listing")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Images uploaded successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid file format"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "404", description = "Listing not found"),
        @ApiResponse(responseCode = "413", description = "File too large"),
        @ApiResponse(responseCode = "500", description = "Server error")
    })
    @PostMapping("/uploadImages/{listingId}")
    public ResponseEntity<?> uploadImages(@PathVariable Long listingId, @RequestParam("files") List<MultipartFile> files) throws IOException {
        List<String> urls = new ArrayList<>();
        for (MultipartFile file : files) {
            String url = cloudStorageService.uploadFile(file); // Devuelve URL pública
            urls.add(url);
        }
        listingService.addImagesToListing(listingId, urls);
        return ResponseEntity.ok(urls);
    }
}

