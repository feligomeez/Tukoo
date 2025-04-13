import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

class ReviewService {
  static const String _baseUrl = 'http://192.168.18.141:8081';

  Future<ReviewsData> getUserReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/reviews/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return ReviewsData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error loading reviews: $e');
    }
  }

  Future<void> createReview({
    required int userId,
    required String reviewerName,
    required int listingId,
    required double rating,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final currentUserId = prefs.getString('user_id');

      if (token == null || currentUserId == null) {
        throw Exception('Not authenticated');
      }

      final Map<String, dynamic> body = {
        'userId': userId,
        'reviewerName': reviewerName,
        'listingId': listingId,
        'rating': rating,
        'comment': comment,
      };

      // Imprimir el body que se va a enviar
      debugPrint('Review request body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      // Imprimir la respuesta
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        // Si la respuesta no es 201 o 200, lanza una excepción
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating review: $e');
      throw Exception('Error creating review: $e');
    }
  }
}