package com.example.listingService.controllers;

import java.util.List;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
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

import com.example.listingService.models.Listing;
import com.example.listingService.models.ListingImage;
import com.example.listingService.services.ListingService;
import com.example.listingService.services.ImageService;

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

    @Autowired
    private ImageService imageService;

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

    @PostMapping("/{listingId}/images")
    public ResponseEntity<String> addImage(
            @PathVariable Long listingId,
            @RequestParam("image") MultipartFile file) {
        try {
            Listing listing = listingService.getListingById(listingId);
            if (listing == null) {
                return ResponseEntity.status(404).body("Listing not found");
            }

            String filename = imageService.saveImage(file);
            ListingImage image = ListingImage.builder()
                .imageUrl(filename)
                .listing(listing)
                .build();
            
            imageService.saveImageEntity(image);
            return ResponseEntity.ok("Image uploaded successfully");
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Failed to upload image: " + e.getMessage());
        }
    }

    @GetMapping("/{listingId}/images")
    public ResponseEntity<List<String>> getListingImages(@PathVariable Long listingId) {
        try {
            List<String> images = imageService.getListingImages(listingId);
            return ResponseEntity.ok(images);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(null);
        }
    }

    @GetMapping("/images/{filename}")
    public ResponseEntity<Resource> getImage(@PathVariable String filename) {
        try {
            Path filePath = Paths.get("uploads/images/" + filename);
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists()) {
                return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (IOException e) {
            return ResponseEntity.status(500).build();
        }
    }
}

