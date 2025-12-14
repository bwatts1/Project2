import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home.dart';
import 'screens/restaurant/restaurant_home.dart';
import 'screens/driver/driver_home.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          
          if (user == null) {
            return const LoginScreen();
          } else {
            // User is logged in, fetch role
            return FutureBuilder<UserModel?>(
              future: authService.getUserDetails(user.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.done) {
                  final UserModel? userModel = userSnapshot.data;
                  if (userModel != null) {
                    switch (userModel.role) {
                      case 'restaurant':
                        return const RestaurantHome();
                      case 'driver':
                        return const DriverHome();
                      case 'customer':
                      default:
                        return const CustomerHome();
                    }
                  } else {
                    // Fallback if user doc missing (shouldn't happen)
                     return const LoginScreen(); 
                  }
                }
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              },
            );
          }
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
