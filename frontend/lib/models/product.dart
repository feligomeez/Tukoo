import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double pricePerDay;
  final String category;
  final String location;
  final int ownerId;
  final String? createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerDay,
    required this.category,
    required this.location,
    required this.ownerId,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
        category: json['category'] as String? ?? '',
        location: json['location'] as String? ?? '',
        ownerId: json['ownerId'] as int? ?? 0,
        createdAt: json['createdAt'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing Product from JSON: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }
}