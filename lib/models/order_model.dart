class OrderItemResponse {
  final String productName;
  final int quantity;
  final double priceAtPurchase;

  OrderItemResponse({
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      productName: json['productName'],
      quantity: json['quantity'],
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
    );
  }
}

class OrderResponse {
  final int orderId;
  final String status;
  final double totalAmount;
  final String addressSummary;
  final List<OrderItemResponse> items;

  OrderResponse({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.addressSummary,
    required this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'],
      status: json['status'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      addressSummary: json['addressSummary'],
      items: (json['items'] as List)
          .map((i) => OrderItemResponse.fromJson(i))
          .toList(),
    );
  }
}
