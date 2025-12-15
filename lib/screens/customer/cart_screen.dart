import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      final authService = AuthService();
      final userDetails = await authService.getUserDetails(user.uid);
      final customerName = userDetails?.name ?? 'Customer';

      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      final order = OrderModel(
        id: orderId,
        customerId: user.uid,
        customerName: customerName,
        restaurantId: cart.restaurantId!,
        restaurantName: cart.restaurantName!,
        items: cart.cartItems
            .map((item) => OrderItem(
                  menuItemId: item.menuItem.id,
                  name: item.menuItem.name,
                  price: item.menuItem.price,
                  quantity: item.quantity,
                ))
            .toList(),
        totalAmount: cart.totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
        deliveryAddress: _addressController.text.trim(),
      );

      await DatabaseService().createOrder(order);
      cart.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add items from a restaurant',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Restaurant name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      cart.restaurantName ?? 'Restaurant',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Cart items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cart.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menuItem.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currencyFormat.format(item.menuItem.price),
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => cart.decrementItem(item.menuItem.id),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.deepOrange,
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => cart.incrementItem(item.menuItem.id),
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.deepOrange,
                                ),
                              ],
                            ),
                            // Item total
                            SizedBox(
                              width: 70,
                              child: Text(
                                _currencyFormat.format(item.totalPrice),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Delivery address
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Order summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(cart.totalAmount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPlacingOrder ? null : () => _placeOrder(cart),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isPlacingOrder
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
