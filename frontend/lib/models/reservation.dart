class Reservation {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final int listingId;
  String? listingTitle;  // Make nullable since we'll fetch it later
  double? pricePerDay;   // Make nullable since we'll fetch it later
  final String status;
  bool hasReview;  // Nueva propiedad

  Reservation({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.listingId,
    this.listingTitle,
    this.pricePerDay,
    required this.status,
    this.hasReview = false,  // Valor por defecto
  });

  int get numberOfDays => endDate.difference(startDate).inDays + 1;
  double get totalPrice => (pricePerDay ?? 0) * numberOfDays;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      listingId: json['listingId'],
      status: json['status'],
    );
  }

  // Method to update listing details
  void updateListingDetails(String title, double price) {
    listingTitle = title;
    pricePerDay = price;
  }
}