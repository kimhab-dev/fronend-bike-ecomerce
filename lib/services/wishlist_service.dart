import 'package:flutter/foundation.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final ValueNotifier<List<Map<String, dynamic>>> itemsNotifier =
      ValueNotifier([]);

  List<Map<String, dynamic>> get items => itemsNotifier.value;

  void toggleWishlist(Map<String, dynamic> item) {
    final List<Map<String, dynamic>> currentItems =
        List.from(itemsNotifier.value);
    final String id = item['_id']?.toString() ?? item['id']?.toString() ?? '';

    final index = currentItems.indexWhere((element) {
      final String elementId =
          element['_id']?.toString() ?? element['id']?.toString() ?? '';
      return elementId == id && id.isNotEmpty;
    });

    if (index != -1) {
      currentItems.removeAt(index);
    } else {
      currentItems.add(item);
    }

    itemsNotifier.value = currentItems;
  }

  bool isSaved(String id) {
    return itemsNotifier.value.any((element) {
      final String elementId =
          element['_id']?.toString() ?? element['id']?.toString() ?? '';
      return elementId == id && id.isNotEmpty;
    });
  }
}
