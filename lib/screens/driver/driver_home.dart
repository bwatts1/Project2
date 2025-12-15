import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/order_model.dart';
import 'delivery_map_screen.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _dbService = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ready_for_pickup':
        return Colors.green;
      case 'out_for_delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final driverId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 Driver Dashboard'),
        backgroundColor: Colors.indigo,
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
            Tab(icon: Icon(Icons.local_shipping), text: 'Available'),
            Tab(icon: Icon(Icons.directions_car), text: 'My Deliveries'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AvailableOrdersTab(
            dbService: _dbService,
            driverId: driverId,
            currencyFormat: _currencyFormat,
            getStatusColor: _getStatusColor,
          ),
          _MyDeliveriesTab(
            dbService: _dbService,
            driverId: driverId,
            currencyFormat: _currencyFormat,
            getStatusColor: _getStatusColor,
          ),
          _HistoryTab(
            dbService: _dbService,
            driverId: driverId,
            currencyFormat: _currencyFormat,
          ),
        ],
      ),
    );
  }
}

class _AvailableOrdersTab extends StatelessWidget {
  final DatabaseService dbService;
  final String driverId;
  final NumberFormat currencyFormat;
  final Color Function(String) getStatusColor;

  const _AvailableOrdersTab({
    required this.dbService,
    required this.driverId,
    required this.currencyFormat,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: dbService.getAvailableOrdersForDrivers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.green.shade300),
                const SizedBox(height: 16),
                const Text(
                  'No orders available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check back soon!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              order: order,
              currencyFormat: currencyFormat,
              getStatusColor: getStatusColor,
              trailing: ElevatedButton.icon(
                onPressed: () async {
                  await dbService.assignDriverToOrder(order.id, driverId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order accepted! Check My Deliveries tab.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MyDeliveriesTab extends StatelessWidget {
  final DatabaseService dbService;
  final String driverId;
  final NumberFormat currencyFormat;
  final Color Function(String) getStatusColor;

  const _MyDeliveriesTab({
    required this.dbService,
    required this.driverId,
    required this.currencyFormat,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: dbService.getDriverOrders(driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data ?? [];
        // Filter to show only active deliveries
        final orders = allOrders.where((o) => o.status == 'out_for_delivery').toList();

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No active deliveries',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Accept orders from the Available tab',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              order: order,
              currencyFormat: currencyFormat,
              getStatusColor: getStatusColor,
              trailing: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeliveryMapScreen(order: order),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await dbService.updateOrderStatus(order.id, 'delivered');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order marked as delivered!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

class _HistoryTab extends StatelessWidget {
  final DatabaseService dbService;
  final String driverId;
  final NumberFormat currencyFormat;

  const _HistoryTab({
    required this.dbService,
    required this.driverId,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: dbService.getDriverOrders(driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data ?? [];
        final orders = allOrders.where((o) => o.status == 'delivered').toList();

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No delivery history',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
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
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(order.restaurantName),
                subtitle: Text(
                  '${order.customerName}\n${DateFormat.yMd().add_jm().format(order.createdAt)}',
                ),
                trailing: Text(
                  currencyFormat.format(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final NumberFormat currencyFormat;
  final Color Function(String) getStatusColor;
  final Widget trailing;

  const _OrderCard({
    required this.order,
    required this.currencyFormat,
    required this.getStatusColor,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: ${order.customerName}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase().replaceAll('_', ' '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Items summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.items.length} item(s)',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ...order.items.take(3).map((item) => Text(
                        '• ${item.quantity}x ${item.name}',
                        style: TextStyle(color: Colors.grey.shade700),
                      )),
                  if (order.items.length > 3)
                    Text(
                      '...and ${order.items.length - 3} more',
                      style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Delivery address
            if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
