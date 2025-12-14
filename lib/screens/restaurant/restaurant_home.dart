import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RestaurantHome extends StatelessWidget {
  const RestaurantHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Manage Orders & Menu (Coming Soon)')),
    );
  }
}
