import 'package:flutter/foundation.dart';
import 'api_service.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal() {
    loadWishlist();
  }

  final ValueNotifier<List<Map<String, dynamic>>> itemsNotifier =
      ValueNotifier([]);

  List<Map<String, dynamic>> get items => itemsNotifier.value;

  Future<void> loadWishlist() async {
    try {
      final wishlistData = await ApiService.getWishlist();
      final List<Map<String, dynamic>> loadedItems = [];

      for (var item in wishlistData) {
        // The API might return product objects directly or wrapped inside 'productId' or 'product'
        Map<String, dynamic> product;
        if (item['productId'] is Map) {
          product = item['productId'];
        } else if (item['product'] is Map) {
          product = item['product'];
        } else {
          product = item;
        }

        loadedItems.add(product);
      }

      itemsNotifier.value = loadedItems;
    } catch (e) {
      debugPrint("Error loading wishlist from API: $e");
    }
  }

  Future<void> toggleWishlist(Map<String, dynamic> item) async {
    final List<Map<String, dynamic>> currentItems =
        List.from(itemsNotifier.value);
    final String id = item['_id']?.toString() ?? item['id']?.toString() ?? '';

    if (id.isEmpty) return; // Cannot toggle without an ID

    final index = currentItems.indexWhere((element) {
      final String elementId =
          element['_id']?.toString() ?? element['id']?.toString() ?? '';
      return elementId == id;
    });

    if (index != -1) {
      currentItems.removeAt(index);
    } else {
      currentItems.add(item);
    }

    // Optimistic UI update
    itemsNotifier.value = currentItems;

    // Persist change to backend
    try {
      await ApiService.toggleWishlist(id);
    } catch (e) {
      debugPrint("Failed to sync wishlist changes: $e");
      // Optional: rollback the UI change if it fails
    }
  }

  bool isSaved(String id) {
    return itemsNotifier.value.any((element) {
      final String elementId =
          element['_id']?.toString() ?? element['id']?.toString() ?? '';
      return elementId == id && id.isNotEmpty;
    });
  }
}
