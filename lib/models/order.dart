class Order {
  final String id;
  final DateTime createdAt;
  final String paymentMethod;
  final double totalAmount;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.createdAt,
    required this.paymentMethod,
    required this.totalAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      paymentMethod: map['payment_method'],
      totalAmount: map['total_amount'].toDouble(),
      items: [], // Items will be loaded separately
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String category;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.category,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'category': category,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'],
      productName: map['product_name'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
      category: map['category'],
    );
  }
}

