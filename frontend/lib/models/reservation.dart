class Reservation {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final int listingId;
  final String listingTitle;
  final double pricePerDay;
  final String status;

  Reservation({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.listingId,
    required this.listingTitle,
    required this.pricePerDay,
    required this.status,
  });

  int get numberOfDays => endDate.difference(startDate).inDays + 1;
  double get totalPrice => pricePerDay * numberOfDays;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      listingId: json['listingId'],
      listingTitle: json['listingTitle'] ?? 'Sin título',
      pricePerDay: (json['pricePerDay'] ?? 0.0).toDouble(),
      status: json['status'],
    );
  }
}