class SellerOrderItem {
  final int orderItemId;
  final int orderId;
  final String productName;
  final int quantity;
  final double priceAtPurchase;
  final String orderStatus;
  final String buyerName;
  final String orderedAt;

  SellerOrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
    required this.orderStatus,
    required this.buyerName,
    required this.orderedAt,
  });

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    return SellerOrderItem(
      orderItemId: json['orderItemId'],
      orderId: json['orderId'],
      productName: json['productName'],
      quantity: json['quantity'],
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
      orderStatus: json['orderStatus'],
      buyerName: json['buyerName'],
      orderedAt: json['orderedAt'] ?? '',
    );
  }
}
