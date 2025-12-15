import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String imageUrl;
  final String cuisine;
  final double rating;
  final bool isOpen;
  final GeoPoint? location;

  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.cuisine = 'General',
    this.rating = 0.0,
    this.isOpen = true,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'cuisine': cuisine,
      'rating': rating,
      'isOpen': isOpen,
      'location': location,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map, String docId) {
    return RestaurantModel(
      id: docId,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? 'Unknown Restaurant',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      cuisine: map['cuisine'] ?? 'General',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isOpen: map['isOpen'] ?? true,
      location: map['location'],
    );
  }
}
