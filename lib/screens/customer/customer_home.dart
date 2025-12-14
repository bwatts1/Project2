import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hungry?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Customer Dashboard (Coming Soon)')),
    );
  }
}
