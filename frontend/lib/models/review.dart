class ReviewsData {
  final List<Review> reviews;
  final double averageRating;
  final Map<String, double> ratingPercentages;
  final int totalReviews;

  ReviewsData({
    required this.reviews,
    required this.averageRating,
    required this.ratingPercentages,
    required this.totalReviews,
  });

  factory ReviewsData.fromJson(Map<String, dynamic> json) {
    return ReviewsData(
      reviews: (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingPercentages: Map<String, double>.from(json['ratingPercentages']),
      totalReviews: json['totalReviews'] as int,
    );
  }
}

class Review {
  final int id;
  final int userId;
  final String reviewerName;
  final int listingId;
  final int rating;
  final String comment;

  Review({
    required this.id,
    required this.userId,
    required this.reviewerName,
    required this.listingId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      userId: json['userId'] as int,
      reviewerName: json['reviewerName'] as String,
      listingId: json['listingId'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );
  }
}