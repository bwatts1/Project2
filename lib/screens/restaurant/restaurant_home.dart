import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/restaurant_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/order_model.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _dbService = DatabaseService();
  RestaurantModel? _restaurant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final restaurant = await _dbService.getRestaurantByOwner(user.uid);
      if (restaurant == null) {
        // Create a new restaurant for this owner
        final authService = AuthService();
        final userDetails = await authService.getUserDetails(user.uid);
        final newRestaurant = RestaurantModel(
          id: user.uid,
          ownerId: user.uid,
          name: userDetails?.name ?? 'My Restaurant',
          description: 'Welcome to our restaurant!',
          cuisine: 'General',
        );
        await _dbService.saveRestaurant(newRestaurant);
        setState(() {
          _restaurant = newRestaurant;
          _isLoading = false;
        });
      } else {
        setState(() {
          _restaurant = restaurant;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_restaurant?.name ?? 'Restaurant Dashboard'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Menu'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MenuTab(restaurant: _restaurant!),
          _OrdersTab(restaurantId: _restaurant!.id),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showAddItemDialog(context),
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String category = 'Main';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Appetizer', 'Main', 'Side', 'Dessert', 'Drink']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => category = val ?? 'Main',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final item = MenuItemModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  restaurantId: _restaurant!.id,
                  name: nameController.text,
                  description: descController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  category: category,
                );
                await _dbService.saveMenuItem(item);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  final RestaurantModel restaurant;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  _MenuTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return StreamBuilder<List<MenuItemModel>>(
      stream: dbService.getMenuItems(restaurant.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No menu items yet'),
                Text('Tap + to add items'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.fastfood, color: Colors.green.shade700),
                ),
                title: Text(item.name),
                subtitle: Text('${item.category} • ${_currencyFormat.format(item.price)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: item.isAvailable,
                      onChanged: (val) async {
                        final updated = MenuItemModel(
                          id: item.id,
                          restaurantId: item.restaurantId,
                          name: item.name,
                          description: item.description,
                          price: item.price,
                          category: item.category,
                          isAvailable: val,
                        );
                        await dbService.saveMenuItem(updated);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await dbService.deleteMenuItem(item.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final String restaurantId;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  _OrdersTab({required this.restaurantId});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready_for_pickup':
        return Colors.green;
      case 'out_for_delivery':
        return Colors.purple;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return StreamBuilder<List<OrderModel>>(
      stream: dbService.getRestaurantOrders(restaurantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No orders yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(order.status),
                  child: const Icon(Icons.receipt, color: Colors.white),
                ),
                title: Text('Order #${order.id.substring(order.id.length - 6)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName),
                    Text(
                      order.status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  _currencyFormat.format(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Items:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.quantity}x ${item.name}'),
                                  Text(_currencyFormat.format(item.price * item.quantity)),
                                ],
                              ),
                            )),
                        const Divider(),
                        if (order.deliveryAddress != null)
                          Text('📍 ${order.deliveryAddress}'),
                        const SizedBox(height: 12),
                        // Status update buttons
                        if (order.status == 'pending')
                          ElevatedButton(
                            onPressed: () async {
                              await dbService.updateOrderStatus(order.id, 'preparing');
                            },
                            child: const Text('Start Preparing'),
                          ),
                        if (order.status == 'preparing')
                          ElevatedButton(
                            onPressed: () async {
                              await dbService.updateOrderStatus(order.id, 'ready_for_pickup');
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Ready for Pickup'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
