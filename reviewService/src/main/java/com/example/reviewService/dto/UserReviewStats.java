package com.example.reviewService.dto;

import com.example.reviewService.models.Review;
import java.util.List;
import java.util.Map;

public class UserReviewStats {
    private List<Review> reviews;
    private double averageRating;
    private Map<Integer, Double> ratingPercentages;
    private int totalReviews;

    public UserReviewStats(List<Review> reviews, double averageRating, 
                          Map<Integer, Double> ratingPercentages, int totalReviews) {
        this.reviews = reviews;
        this.averageRating = averageRating;
        this.ratingPercentages = ratingPercentages;
        this.totalReviews = totalReviews;
    }

    // Getters and setters
    public List<Review> getReviews() {
        return reviews;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public Map<Integer, Double> getRatingPercentages() {
        return ratingPercentages;
    }

    public int getTotalReviews() {
        return totalReviews;
    }
}