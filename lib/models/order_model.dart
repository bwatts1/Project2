import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String restaurantId;
  final String restaurantName;
  final String? driverId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'pending', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled'
  final DateTime createdAt;
  final String? deliveryAddress;
  final GeoPoint? deliveryLocation;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.restaurantId,
    required this.restaurantName,
    this.driverId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    required this.createdAt,
    this.deliveryAddress,
    this.deliveryLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'driverId': driverId,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryAddress': deliveryAddress,
      'deliveryLocation': deliveryLocation,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      driverId: map['driverId'],
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryAddress: map['deliveryAddress'],
      deliveryLocation: map['deliveryLocation'],
    );
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? restaurantId,
    String? restaurantName,
    String? driverId,
    List<OrderItem>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    String? deliveryAddress,
    GeoPoint? deliveryLocation,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      driverId: driverId ?? this.driverId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
    );
  }
}
