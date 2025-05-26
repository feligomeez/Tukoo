package com.example.reviewService.controllers;

import com.example.reviewService.dto.UserReviewStats;
import com.example.reviewService.models.Review;
import com.example.reviewService.services.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/reviews")
@Tag(name = "Reviews", description = "API para gestionar reviews")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @Operation(summary = "Obtener reviews por usuario")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Reviews encontradas"),
        @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @GetMapping("/{userId}")
    public ResponseEntity<UserReviewStats> getReviewsByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(reviewService.getReviewsByUser(userId));
    }

    @Operation(summary = "Obtener todas las reviews")
    @GetMapping
    public ResponseEntity<List<Review>> getReviews() {
        return ResponseEntity.ok(reviewService.getReviews());
    }

    @Operation(summary = "Crear una nueva review")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Review creada correctamente"),
        @ApiResponse(responseCode = "500", description = "Error al crear la review")
    })
    @PostMapping
    public ResponseEntity<String> createReview(@RequestBody Review review) {
        String message = reviewService.createReview(review);
        if(message.contains("Review created successfully.")){
            return ResponseEntity.ok(message);
        }
        return ResponseEntity.status(500).body(message);
    }

    @PutMapping("/{id}")
    public ResponseEntity<String> updateReview(@PathVariable Long id, @RequestBody Review review) {
        String message = reviewService.updateReview(id, review);
        if(message.contains("Review updated successfully.")){
            return ResponseEntity.ok(message);
        }
        return ResponseEntity.status(500).body(message);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteReview(@PathVariable Long id) {
        return ResponseEntity.ok(reviewService.deleteReview(id));
    }
}
