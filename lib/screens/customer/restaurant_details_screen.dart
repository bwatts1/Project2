import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_model.dart';
import '../../models/menu_item_model.dart';
import '../../services/database_service.dart';
import '../../providers/cart_provider.dart';
import 'package:intl/intl.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final RestaurantModel restaurant;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Restaurant header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.orange.shade200],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      restaurant.cuisine,
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
                if (restaurant.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: StreamBuilder<List<MenuItemModel>>(
              stream: dbService.getMenuItems(restaurant.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final menuItems = snapshot.data ?? [];

                if (menuItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No menu items yet'),
                      ],
                    ),
                  );
                }

                // Group by category
                final categories = <String, List<MenuItemModel>>{};
                for (var item in menuItems) {
                  categories.putIfAbsent(item.category, () => []).add(item);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories.keys.elementAt(index);
                    final items = categories[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...items.map((item) => _MenuItemCard(
                              item: item,
                              restaurant: restaurant,
                              currencyFormat: _currencyFormat,
                            )),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final RestaurantModel restaurant;
  final NumberFormat currencyFormat;

  const _MenuItemCard({
    required this.item,
    required this.restaurant,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fastfood,
                size: 40,
                color: Colors.deepOrange.shade300,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(item.price),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // Add button
            IconButton(
              onPressed: item.isAvailable
                  ? () {
                      cart.addItem(item, restaurant.id, restaurant.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () => cart.decrementItem(item.id),
                          ),
                        ),
                      );
                    }
                  : null,
              icon: Icon(
                Icons.add_circle,
                size: 36,
                color: item.isAvailable ? Colors.deepOrange : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
