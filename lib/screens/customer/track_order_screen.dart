import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import 'review_screen.dart';

class TrackOrderScreen extends StatelessWidget {
  final String orderId;

  TrackOrderScreen({super.key, required this.orderId});

  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  final List<Map<String, dynamic>> _statusSteps = [
    {'status': 'pending', 'label': 'Order Placed', 'icon': Icons.receipt},
    {'status': 'preparing', 'label': 'Preparing', 'icon': Icons.restaurant},
    {'status': 'ready_for_pickup', 'label': 'Ready for Pickup', 'icon': Icons.check_circle},
    {'status': 'out_for_delivery', 'label': 'Out for Delivery', 'icon': Icons.delivery_dining},
    {'status': 'delivered', 'label': 'Delivered', 'icon': Icons.done_all},
  ];

  int _getStatusIndex(String status) {
    return _statusSteps.indexWhere((s) => s['status'] == status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final order = OrderModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );

          final currentStatusIndex = _getStatusIndex(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order header
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '#${order.id.substring(order.id.length - 6)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.restaurant, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Text(
                              order.restaurantName,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.deliveryAddress ?? 'No address',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status timeline
                const Text(
                  'Order Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...List.generate(_statusSteps.length, (index) {
                  final step = _statusSteps[index];
                  final isCompleted = currentStatusIndex >= index;
                  final isCurrent = currentStatusIndex == index;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted ? Colors.deepOrange : Colors.grey.shade300,
                              border: isCurrent
                                  ? Border.all(color: Colors.deepOrange, width: 3)
                                  : null,
                            ),
                            child: Icon(
                              step['icon'] as IconData,
                              color: isCompleted ? Colors.white : Colors.grey,
                              size: 20,
                            ),
                          ),
                          if (index < _statusSteps.length - 1)
                            Container(
                              width: 3,
                              height: 40,
                              color: isCompleted ? Colors.deepOrange : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['label'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isCompleted ? Colors.black : Colors.grey,
                                ),
                              ),
                              if (isCurrent && order.status != 'delivered')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'In Progress...',
                                    style: TextStyle(
                                      color: Colors.deepOrange.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              SizedBox(height: index < _statusSteps.length - 1 ? 24 : 0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Order items
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.quantity}x ${item.name}'),
                                  Text(_currencyFormat.format(item.price * item.quantity)),
                                ],
                              ),
                            )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _currencyFormat.format(order.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Driver info (if out for delivery)
                if (order.status == 'out_for_delivery' && order.driverId != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.directions_car, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver on the way!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Your order is being delivered'),
                              ],
                            ),
                          ),
                          const Icon(Icons.delivery_dining, color: Colors.blue, size: 32),
                        ],
                      ),
                    ),
                  ),
                ],

                // Leave Review button (if delivered)
                if (order.status == 'delivered') ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(order: order),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star),
                      label: const Text('Leave a Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
