import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import '../widgets/custom_app_bar.dart';

class ProductSaveScreen extends StatefulWidget {
  const ProductSaveScreen({super.key});

  @override
  State<ProductSaveScreen> createState() => _ProductSaveScreenState();
}

class _ProductSaveScreenState extends State<ProductSaveScreen> {
  @override
  void initState() {
    super.initState();
    WishlistService().loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100A16),
      appBar: const CustomAppBar(),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: WishlistService().itemsNotifier,
        builder: (context, savedItems, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5A8C).withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Wishlist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${savedItems.length} saved bikes',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: savedItems.isEmpty
                    ? _buildEmptyState()
                    : _buildSavedItemsList(savedItems),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_remove_outlined,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No saved bikes yet',
            style: TextStyle(
              color: Color(0xFF8B5A8C),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the heart icon on any bike to save it here',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5A8C), Color(0xFF7CB670)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5A8C).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // The user can switch tabs manually, or this could use a callback
                },
                child: const Center(
                  child: Text(
                    'Explore Bikes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60), // Offset for vertical centering
        ],
      ),
    );
  }

  Widget _buildSavedItemsList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final bike = items[index];
        final String bikeId =
            bike['_id']?.toString() ?? bike['id']?.toString() ?? '';

        String rawImage =
            bike['image'] ?? bike['image_url'] ?? bike['imageUrl'] ?? '';
        String imageUrl = rawImage;
        if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
          imageUrl = ApiService.baseUrl + "/" + rawImage;
        }

        String categoryName = bike['category_name'] ?? 'Sport';
        if (bike['category'] != null) {
          final cat = bike['category'];
          if (cat is Map && cat['name'] != null) {
            categoryName = cat['name'].toString();
          }
        }

        return GestureDetector(
          onTap: () {
            if (bikeId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailScreen(productId: bikeId, initialData: bike),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF251C2B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageUrl.isEmpty
                      ? Container(
                          width: 100, height: 100, color: Colors.grey[800])
                      : Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              width: 100, height: 100, color: Colors.grey[800]),
                        ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bike['name'] ?? 'Unknown',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(bike['description'] ?? "2026 Edition",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(categoryName,
                            style: const TextStyle(
                                color: Colors.purpleAccent, fontSize: 10)),
                      ),
                      const SizedBox(height: 8),
                      Text("\$${bike['price'] ?? ''}",
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        WishlistService().toggleWishlist(bike);
                      },
                      child:
                          const Icon(Icons.favorite, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        final priceStr = bike['price']?.toString() ?? '0';
                        final doublePrice = double.tryParse(priceStr) ?? 0.0;
                        CartService().addToCart(CartItem(
                          id: bikeId.isNotEmpty
                              ? bikeId
                              : DateTime.now().toString(),
                          name: bike['name'] ?? 'Unknown',
                          edition: categoryName.isNotEmpty
                              ? categoryName
                              : 'Standard Edition',
                          price: doublePrice,
                          imageUrl: imageUrl,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${bike['name']} added to cart!'),
                            backgroundColor: const Color(0xFF7B5A96),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF8B5A8C),
                              Color(0xFF7CB670),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.shopping_cart_outlined,
                            color: Colors.white, size: 20),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
