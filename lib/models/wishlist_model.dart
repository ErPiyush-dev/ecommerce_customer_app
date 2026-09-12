class WishlistItem {
  final int wishlistItemId;
  final int productId;
  final String productName;
  final String? imageUrl;
  final double price;

  WishlistItem({
    required this.wishlistItemId,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.price,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      wishlistItemId: json['wishlistItemId'],
      productId: json['productId'],
      productName: json['productName'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
