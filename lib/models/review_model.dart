class Review {
  final int id;
  final String userName;
  final int rating;
  final String? comment;
  final String createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userName: json['userName'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
