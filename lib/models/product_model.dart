class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String categoryName;
  final String sellerName;
  final bool approved;
  final String? rejectionReason;   // Naya field

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.categoryName,
    required this.sellerName,
    required this.approved,
    this.rejectionReason,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      imageUrl: json['imageUrl'],
      categoryName: json['categoryName'] ?? '',
      sellerName: json['sellerName'] ?? '',
      approved: json['approved'] ?? false,
      rejectionReason: json['rejectionReason'],
    );
  }
}