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
  final String? category;

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
    this.category,
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
      category: json['category'],
    );
  }
}