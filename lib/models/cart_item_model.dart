class CartItem {
  final int cartItemId;
  final int productId;
  final String productName;
  final String? imageUrl;
  final double price;
  final int quantity;
  final double totalPrice;

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['cartItemId'],
      productId: json['productId'],
      productName: json['productName'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}
