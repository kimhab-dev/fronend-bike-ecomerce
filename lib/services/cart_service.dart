import 'package:flutter/foundation.dart';
import 'api_service.dart';

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
  CartService._internal() {
    loadCart();
  }

  // ValueNotifier to allow UI to listen to cart changes
  final ValueNotifier<List<CartItem>> itemsNotifier = ValueNotifier([]);

  List<CartItem> get items => itemsNotifier.value;

  Future<void> loadCart() async {
    try {
      final cartData = await ApiService.getCart();
      final List<CartItem> loadedItems = [];

      for (var item in cartData) {
        final quantity = item['quantity'] ?? 1;

        Map<String, dynamic> product;
        if (item['productId'] is Map) {
          product = item['productId'];
        } else if (item['product'] is Map) {
          product = item['product'];
        } else {
          product = item;
        }

        final pId = product['_id']?.toString() ??
            product['id']?.toString() ??
            item['id']?.toString() ??
            '';
        final name = product['name'] ?? 'Unknown';

        String edition = 'Standard Edition';
        if (product['category'] != null) {
          final cat = product['category'];
          if (cat is Map && cat['name'] != null) {
            edition = cat['name'].toString();
          } else if (product['category_name'] != null) {
            edition = product['category_name'].toString();
          }
        }

        final priceStr = product['price']?.toString() ?? '0';
        final doublePrice = double.tryParse(priceStr) ?? 0.0;

        String rawImage = product['image'] ??
            product['image_url'] ??
            product['imageUrl'] ??
            '';
        String imageUrl = rawImage;
        if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
          imageUrl = "${ApiService.baseUrl}/$rawImage";
        }

        if (pId.isNotEmpty) {
          loadedItems.add(CartItem(
            id: pId,
            name: name,
            edition: edition,
            price: doublePrice,
            imageUrl: imageUrl,
            quantity: quantity,
          ));
        }
      }

      itemsNotifier.value = loadedItems;
    } catch (e) {
      debugPrint("Error loading cart from API: $e");
    }
  }

  Future<void> addToCart(CartItem item) async {
    final List<CartItem> currentItems = List.from(itemsNotifier.value);

    // Optimistic UI update
    final index = currentItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      // increase quantity
      currentItems[index].quantity += 1;
    } else {
      currentItems.add(item);
    }

    itemsNotifier.value = currentItems;

    // API Post
    try {
      await ApiService.addToCart(item.id, 1);
    } catch (e) {
      debugPrint("Failed to sync cart additions: $e");
    }
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
