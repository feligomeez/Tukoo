import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'http://192.168.1.136:8080';

  Future<List<Product>> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Token not found');
    }
        
    final response = await http.get(
      Uri.parse('$_baseUrl/listing'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Product> products = body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      debugPrint('Fetching product with ID: $id');
      final response = await http.get(
        Uri.parse('$_baseUrl/listing/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      throw Exception('Error loading product details: $e');
    }
  }

  Future<bool> createListing({
    required String title,
    required String description,
    required double pricePerDay,
    required String category,
    required String location,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        print('Token or userId not found');
        return false;
      }

      final requestBody = {
        'title': title,
        'description': description,
        'pricePerDay': pricePerDay,
        'category': category,
        'ownerId': int.parse(userId),
        'location': location
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/listing'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating listing: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }
}

