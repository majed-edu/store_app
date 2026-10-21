import 'package:store_app/core/app_config.dart';

enum OrderStatus { placed, shipped, delivered }

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.category,
    required this.price,
    required this.quantity,
  });

  final dynamic productId;
  final String title, image, category;
  final double price;
  final int quantity;

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'title': title,
    'image': image,
    'category': category,
    'price': price,
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'],
    title: json['title'] as String,
    image: json['image'] as String,
    category: json['category'] as String,
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'] as int,
  );
}

class Order {
  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.date,
    required this.items,
    required this.address,
    this.status = OrderStatus.placed,
    this.fromServer = false,
  });

  final String id;
  final int userId;
  final String customerName;
  final DateTime date;
  final List<OrderItem> items;
  final String address;
  OrderStatus status;

  final bool fromServer;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get shipping =>
      subtotal >= AppConfig.freeShippingThreshold || items.isEmpty
      ? 0
      : AppConfig.shippingFee;

  double get total => subtotal + shipping;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'customerName': customerName,
    'date': date.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
    'address': address,
    'status': status.name,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    userId: json['userId'] as int,
    customerName: json['customerName'] as String,
    date: DateTime.parse(json['date'] as String),
    items: (json['items'] as List<dynamic>)
        .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    address: json['address'] as String,
    status: OrderStatus.values.byName(json['status'] as String),
  );
}
