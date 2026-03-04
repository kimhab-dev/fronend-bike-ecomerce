import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String edition;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.edition,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartService {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // ValueNotifier to allow UI to listen to cart changes
  final ValueNotifier<List<CartItem>> itemsNotifier = ValueNotifier([]);

  List<CartItem> get items => itemsNotifier.value;

  void addToCart(CartItem item) {
    final List<CartItem> currentItems = List.from(itemsNotifier.value);

    // Check if item already exists
    final index = currentItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      // increase quantity
      currentItems[index].quantity += 1;
    } else {
      currentItems.add(item);
    }

    itemsNotifier.value = currentItems;
  }

  void removeFromCart(String id) {
    final List<CartItem> currentItems = List.from(itemsNotifier.value);
    currentItems.removeWhere((item) => item.id == id);
    itemsNotifier.value = currentItems;
  }

  void updateQuantity(String id, int change) {
    final List<CartItem> currentItems = List.from(itemsNotifier.value);
    final index = currentItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      currentItems[index].quantity += change;
      if (currentItems[index].quantity <= 0) {
        currentItems.removeAt(index);
      }
      itemsNotifier.value = currentItems;
    }
  }

  double get subtotal {
    double total = 0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }
}
