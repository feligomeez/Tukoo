package com.example.reviewService.services;

import com.example.reviewService.dto.UserReviewStats;

import com.example.reviewService.models.Review;
import com.example.reviewService.repositories.ReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository repository;

    public UserReviewStats getReviewsByUser(Long userId) {
        List<Review> reviews = repository.findByUserId(userId);
        
        // Calculate average rating
        double averageRating = reviews.stream()
                .mapToInt(Review::getRating)
                .average()
                .orElse(0.0);

        // Calculate rating percentages
        Map<Integer, Double> ratingPercentages = new HashMap<>();
        int totalReviews = reviews.size();
        
        for (int i = 1; i <= 5; i++) {
            final int rating = i;
            long count = reviews.stream()
                    .filter(review -> review.getRating() == rating)
                    .count();
            double percentage = totalReviews > 0 ? (count * 100.0) / totalReviews : 0.0;
            ratingPercentages.put(i, Math.round(percentage * 100.0) / 100.0); // Round to 2 decimals
        }

        return new UserReviewStats(reviews, 
                                 Math.round(averageRating * 100.0) / 100.0, 
                                 ratingPercentages, 
                                 totalReviews);
    }

    public List<Review> getReviews() {
        return repository.findAll();
    }

    public List<Review> getReviewsByListing(Long listingId) {
        return repository.findByListingId(listingId);
    }

    public String createReview(Review review) {
        if (review.getRating() < 1 || review.getRating() > 5) {
            return "Rating must be between 1 and 5";
        } 
        repository.save(review);
        return "Review created successfully.";
    }

    public String updateReview(Long id, Review newReview) {
        Review review = repository.findById(id).orElse(null);
        if (review!=null) {
            review.setRating(newReview.getRating());
            review.setComment(newReview.getComment());
            repository.save(review);
            return "Review updated successfully.";
        }
        return "Review not found.";
    }

    public String deleteReview(Long id) {
        repository.deleteById(id);
        return "Review deleted successfully.";
    }
}
