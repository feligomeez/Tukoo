package com.example.listingService.services;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.listingService.models.Listing;
import com.example.listingService.repository.ListingRepository;

@Service
public class ListingService {
    @Autowired
    private ListingRepository repository;

    private DateTimeFormatter formatDate = DateTimeFormatter.ofPattern("dd/MM/yy HH:mm");

    public List<Listing> getListingByStatus(String status){
        return repository.findByStatus(status);
    }

    public Listing getListingById(Long id) {
        Listing listing = repository.findById(id).orElse(null);
        return listing; // Si no existe, retorna null
    }

    public List<Listing> getListings() {
        return repository.findAll();
    }

    public List<Listing> getListingsByOwnerId(Long ownerId) {
        // Lógica para obtener los listings por ownerId
        return repository.findByOwnerId(ownerId);
    }

    public String createListing(Listing listing){
        listing.setStatus("ACTIVE");
        listing.setCreatedAt(LocalDateTime.now().format(formatDate));
        repository.save(listing);
        return "Listing created successfully.";
    }

    public String updateListing(Long id, Listing listingDetails) {
        Listing listing = repository.findById(id).orElse(null);
        if (listing == null) {
            return "Listing not found.";
        }
        if (listingDetails.getTitle() != null) {
            listing.setTitle(listingDetails.getTitle());
        }
        if (listingDetails.getDescription() != null) {
            listing.setDescription(listingDetails.getDescription());
        }
        if (listingDetails.getPricePerDay() != null) {
            listing.setPricePerDay(listingDetails.getPricePerDay());
        }
        if (listingDetails.getLocation() != null) {
            listing.setLocation(listingDetails.getLocation());
        }
        listing.setUpdatedAt(LocalDateTime.now().format(formatDate));
        repository.save(listing);
        return "Listing updated successfully.";
    }

    public String updateListingStatus(Long id, String newStatus) {
        List<String> validStatuses = List.of("ACTIVE", "EXPIRED", "RESERVED", "RENTED", "FINISHED");
        
        if (!validStatuses.contains(newStatus.toUpperCase())) {
            return "Invalid status. Valid statuses are: ACTIVE, EXPIRED, RESERVED, RENTED, FINISHED.";
        }
    
        Listing listing = repository.findById(id).orElse(null);
        if (listing == null) {
            return "Listing not found.";
        }
    
        listing.setStatus(newStatus.toUpperCase());
        listing.setUpdatedAt(LocalDateTime.now().format(formatDate));
        repository.save(listing);
        
        return "Listing status updated to " + newStatus.toUpperCase() + ".";
    }

    public String deleteListing(Long id){
        repository.deleteById(id);
        return "Listing deleted successfully";
    }
    
}
