import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
}

class Product {
  final int id;
  final String title;
  final String description;
  final double pricePerDay;
  final int ownerId;
  final String location;
  final String status;
  final String createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerDay,
    required this.ownerId,
    required this.location,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pricePerDay: json['pricePerDay'],
      ownerId: json['ownerId'],
      location: json['location'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}