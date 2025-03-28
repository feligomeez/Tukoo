import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewsView extends StatefulWidget {
  const ReviewsView({super.key});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  final ReviewService _reviewService = ReviewService();
  ReviewsData? _reviewsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviewsData = await _reviewService.getUserReviews();
      setState(() {
        _reviewsData = reviewsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // Muestra un mensaje de error en pantalla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las reseñas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reseñas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    // Rating summary
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _reviewsData!.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  final rating = _reviewsData!.averageRating;
                                  return Icon(
                                    index < rating.floor()
                                        ? Icons.star
                                        : index < rating
                                            ? Icons.star_half
                                            : Icons.star_border,
                                    color: Colors.amber,
                                    size: 24,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Basado en ${_reviewsData!.totalReviews} reseñas',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Star statistics
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          for (var i = 5; i >= 1; i--)
                            _buildStarBar(
                              i,
                              _reviewsData!.ratingPercentages[i.toString()]! /
                                  100,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Reviews list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _reviewsData!.reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviewsData!.reviews[index];
                          return _buildReviewCard(review);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStarBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),              
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} meses atrás';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} días atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else {
      return '${difference.inMinutes} minutos atrás';
    }
  }
}
