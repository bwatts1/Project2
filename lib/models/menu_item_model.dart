class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;

  MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description = '',
    required this.price,
    this.imageUrl = '',
    this.category = 'Main',
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return MenuItemModel(
      id: docId,
      restaurantId: map['restaurantId'] ?? '',
      name: map['name'] ?? 'Unknown Item',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'Main',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
