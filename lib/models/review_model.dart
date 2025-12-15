import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String restaurantId;
  final String? driverId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.restaurantId,
    this.driverId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'restaurantId': restaurantId,
      'driverId': driverId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      id: docId,
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      driverId: map['driverId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
