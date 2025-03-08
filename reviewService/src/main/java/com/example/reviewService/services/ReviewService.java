package com.example.reviewService.services;

import com.example.reviewService.models.Review;
import com.example.reviewService.repositories.ReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository repository;

    public List<Review> getReviewsByUser(String userId) {
        return repository.findByUserId(userId);
    }

    public List<Review> getReviewsByListing(String listingId) {
        return repository.findByListingId(listingId);
    }

    public String createReview(Review review) {
        if (review.getRating() < 1 || review.getRating() > 5) {
            return "Rating must be between 1 and 5";
        } 
        repository.save(review);
        return "Review created successfully.";
    }

    public String updateReview(String id, Review newReview) {
        Review review = repository.findById(id).orElse(null);
        if (review!=null) {
            review.setRating(newReview.getRating());
            review.setComment(newReview.getComment());
            repository.save(review);
            return "Review updated successfully.";
        }
        return "Review not found.";
    }

    public String deleteReview(String id) {
        repository.deleteById(id);
        return "Review deleted successfully.";
    }
}
