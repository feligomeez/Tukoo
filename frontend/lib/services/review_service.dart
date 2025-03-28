import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

class ReviewService {
  static const String _baseUrl = 'http://192.168.1.136:8081';

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
}