import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===================== RESTAURANTS =====================

  // Get all restaurants (for customer discovery)
  Stream<List<RestaurantModel>> getRestaurants() {
    return _firestore
        .collection('restaurants')
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get restaurant by owner ID (for restaurant dashboard)
  Future<RestaurantModel?> getRestaurantByOwner(String ownerId) async {
    final snapshot = await _firestore
        .collection('restaurants')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return RestaurantModel.fromMap(
          snapshot.docs.first.data(), snapshot.docs.first.id);
    }
    return null;
  }

  // Create or update restaurant
  Future<void> saveRestaurant(RestaurantModel restaurant) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurant.id)
        .set(restaurant.toMap());
  }

  // ===================== MENU ITEMS =====================

  // Get menu items for a restaurant
  Stream<List<MenuItemModel>> getMenuItems(String restaurantId) {
    return _firestore
        .collection('menuItems')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add/update menu item
  Future<void> saveMenuItem(MenuItemModel item) async {
    await _firestore.collection('menuItems').doc(item.id).set(item.toMap());
  }

  // Delete menu item
  Future<void> deleteMenuItem(String itemId) async {
    await _firestore.collection('menuItems').doc(itemId).delete();
  }

  // ===================== ORDERS =====================

  // Create order
  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  // Get orders for customer
  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get orders for restaurant
  Stream<List<OrderModel>> getRestaurantOrders(String restaurantId) {
    return _firestore
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get orders available for drivers (ready for pickup)
  Stream<List<OrderModel>> getAvailableOrdersForDrivers() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'ready_for_pickup')
        .where('driverId', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get orders assigned to a driver
  Stream<List<OrderModel>> getDriverOrders(String driverId) {
    return _firestore
        .collection('orders')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({'status': status});
  }

  // Assign driver to order
  Future<void> assignDriverToOrder(String orderId, String driverId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'driverId': driverId,
      'status': 'out_for_delivery',
    });
  }
}
