import 'dart:convert';
import 'dart:io';
import 'package:frontend/models/reservation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
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
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes)); // Decodifica en UTF-8
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
        return Product.fromJson(json.decode(utf8.decode(response.bodyBytes))); // Decodifica en UTF-8
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      throw Exception('Error loading product details: $e');
    }
  }

  Future<int?> createListing({
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
        debugPrint('Token or userId not found');
        return null;
      }

      final requestBody = {
        'title': title,
        'description': description,
        'pricePerDay': pricePerDay,
        'category': category,
        'ownerId': int.parse(userId),
        'location': location
      };

      debugPrint('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/listing'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final responseData = json.decode(utf8.decode(response.bodyBytes)); // Decodifica en UTF-8
          if (responseData is Map<String, dynamic> && responseData.containsKey('id')) {
            return responseData['id'] as int;
          } else {
            debugPrint('Response does not contain id field: $responseData');
            return null;
          }
        } catch (e) {
          debugPrint('Error parsing response JSON: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating listing: $e');
      return null;
    }
  }

  Future<void> uploadImage(File imageFile, int listingId) async {
    try {
      debugPrint('Starting image upload for listing ID: $listingId');
      debugPrint('Image file path: ${imageFile.path}');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('Token not found in SharedPreferences');
        throw Exception('Token not found');
      }

      final url = '$_baseUrl/listing/$listingId/images';
      debugPrint('Upload URL: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      });
      debugPrint('Headers added: ${request.headers}');
      
      // Get file extension and determine content type
      final extension = path.extension(imageFile.path).toLowerCase();
      final mimeType = extension == '.png' ? 'png' : 'jpeg';
      debugPrint('File type detected: $mimeType');

      // Add the file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', mimeType),
        ),
      );
      debugPrint('File added to request');
      
      // Send request
      debugPrint('Sending request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode != 200) {
        debugPrint('Upload failed with status: ${response.statusCode}');
        throw Exception('Failed to upload image: ${response.statusCode}\nBody: ${response.body}');
      }

      debugPrint('Image upload successful');
    } catch (e) {
      debugPrint('Error in uploadImage: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> uploadImages(List<File> imageFiles, int listingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      for (var imageFile in imageFiles) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/listing/$listingId/images'),
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
        
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        debugPrint('Image upload response: $responseBody');
        
        if (response.statusCode != 200) {
          throw Exception('Failed to upload image: ${response.statusCode}');
        }
      }
      debugPrint('All images uploaded successfully');
    } catch (e) {
      debugPrint('Error uploading images: $e');
      throw Exception('Error uploading images: $e');
    }
  }

  Future<void> createListingWithImage({
    required String title,
    required String description,
    required double pricePerDay,
    required String category,
    required String location,
    required File imageFile,
  }) async {
    try {
      // 1. Create listing and get ID
      final listingId = await createListing(
        title: title,
        description: description,
        pricePerDay: pricePerDay,
        category: category,
        location: location,
      );

      if (listingId == null) {
        throw Exception('Failed to create listing');
      }

      // 2. Upload image
      await uploadImage(imageFile, listingId);

      debugPrint('Listing created with ID: $listingId and image uploaded successfully');
    } catch (e) {
      debugPrint('Error in createListingWithImage: $e');
      throw Exception('Failed to create listing with image: $e');
    }
  }

  Future<void> createListingWithImages({
    required String title,
    required String description,
    required double pricePerDay,
    required String category,
    required String location,
    required List<File> imageFiles,
  }) async {
    try {
      debugPrint('Starting createListingWithImages process...');
      debugPrint('Number of images to upload: ${imageFiles.length}');

      // Validate we have images to upload
      if (imageFiles.isEmpty) {
        debugPrint('Error: No images provided');
        throw Exception('No images provided');
      }

      debugPrint('Creating listing with title: $title');
      // 1. Create listing and get ID
      final listingId = await createListing(
        title: title,
        description: description,
        pricePerDay: pricePerDay,
        category: category,
        location: location,
      );

      if (listingId == null) {
        debugPrint('Error: Listing creation failed - no ID returned');
        throw Exception('Failed to create listing: No ID returned');
      }
      debugPrint('Listing created successfully with ID: $listingId');

      // 2. Validate image files
      debugPrint('Validating image files...');
      for (var imageFile in imageFiles) {
        debugPrint('Checking file: ${imageFile.path}');
        if (!await imageFile.exists()) {
          debugPrint('Error: Image file does not exist: ${imageFile.path}');
          throw Exception('Image file does not exist: ${imageFile.path}');
        }
      }
      debugPrint('All image files validated successfully');

      // 3. Upload images
      debugPrint('Starting image upload process...');
      await uploadImages(imageFiles, listingId);
      debugPrint('All images uploaded successfully for listing ID: $listingId');

    } on SocketException catch (e) {
      debugPrint('Network error occurred: $e');
      throw Exception('Connection error: Please check your internet connection');
    } on HttpException catch (e) {
      debugPrint('HTTP error occurred: $e');
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('Data format error occurred: $e');
      throw Exception('Invalid data format: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error occurred: $e');
      throw Exception('Failed to create listing with images: $e');
    }
  }

  Future<List<String>> getProductImages(int listingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/listing/$listingId/images'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> imageList = json.decode(response.body);
        return imageList.cast<String>();
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching images: $e');
      throw Exception('Error loading images: $e');
    }
  }

  Future<List<Product>> getUserProducts(int ownerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/listing/owner/$ownerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(utf8.decode(response.bodyBytes)); // Decodifica en UTF-8
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user products');
      }
    } catch (e) {
      throw Exception('Error loading user products: $e');
    }
  }

  Future<void> updateListing({
    required int listingId,
    required String title,
    required String description,
    required double pricePerDay,
    required String category,
    required String location,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/listing/$listingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'pricePerDay': pricePerDay,
          'category': category,
          'location': location,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update listing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating listing: $e');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/listing/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  Future<void> createReservation({
    required DateTime startDate,
    required DateTime endDate,
    required int listingId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('Token or user ID not found');
      }

      debugPrint('Creating reservation:');
      debugPrint('Start Date: $startDate');
      debugPrint('End Date: $endDate');
      debugPrint('Listing ID: $listingId');
      debugPrint('User ID: $userId');

      final response = await http.post(
        Uri.parse('$_baseUrl/reservations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'listingId': listingId,
          'userId': int.parse(userId),
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create reservation: ${response.statusCode}');
      }

      debugPrint('Reservation created successfully');
    } catch (e) {
      debugPrint('Error creating reservation: $e');
      throw Exception('Error creating reservation: $e');
    }
  }

  Future<List<Reservation>> getReceivedReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('Token or user ID not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/reservations/owner/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading reservations: $e');
    }
  }

  Future<List<Reservation>> getMadeReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('Token or user ID not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/reservations/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load made reservations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading made reservations: $e');
    }
  }

  Future<void> confirmReservation(int reservationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/reservations/$reservationId/confirm'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to confirm reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error confirming reservation: $e');
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/reservations/$reservationId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error canceling reservation: $e');
    }
  }
}

