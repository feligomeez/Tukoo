package com.example.reviewService.controllers;

import com.example.reviewService.models.Review;
import com.example.reviewService.services.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/reviews")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @GetMapping("/{userId}")
    public ResponseEntity<List<Review>> getReviewsByUser(@PathVariable String userId) {
        return ResponseEntity.ok(reviewService.getReviewsByUser(userId));
    }

    @PostMapping
    public ResponseEntity<String> createReview(@RequestBody Review review) {
        String message = reviewService.createReview(review);
        if(message.contains("Review created successfully.")){
            return ResponseEntity.ok(message);
        }
        return ResponseEntity.status(500).body(message);
    }

    @PutMapping("/{id}")
    public ResponseEntity<String> updateReview(@PathVariable String id, @RequestBody Review review) {
        String message = reviewService.updateReview(id, review);
        if(message.contains("Review updated successfully.")){
            return ResponseEntity.ok(message);
        }
        return ResponseEntity.status(500).body(message);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteReview(@PathVariable String id) {
        return ResponseEntity.ok(reviewService.deleteReview(id));
    }
}
