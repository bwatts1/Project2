import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';

class CartItem {
  final MenuItemModel menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  double get totalPrice => menuItem.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _restaurantId;
  String? _restaurantName;

  Map<String, CartItem> get items => {..._items};
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isEmpty => _items.isEmpty;

  void addItem(MenuItemModel menuItem, String restaurantId, String restaurantName) {
    // If cart has items from a different restaurant, clear it first
    if (_restaurantId != null && _restaurantId != restaurantId) {
      clear();
    }

    _restaurantId = restaurantId;
    _restaurantName = restaurantName;

    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity++;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem);
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.remove(menuItemId);
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  void decrementItem(String menuItemId) {
    if (!_items.containsKey(menuItemId)) return;
    
    if (_items[menuItemId]!.quantity > 1) {
      _items[menuItemId]!.quantity--;
    } else {
      removeItem(menuItemId);
    }
    notifyListeners();
  }

  void incrementItem(String menuItemId) {
    if (_items.containsKey(menuItemId)) {
      _items[menuItemId]!.quantity++;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }

  List<CartItem> get cartItems => _items.values.toList();
}
