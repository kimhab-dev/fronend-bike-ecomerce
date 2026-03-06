import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'addToCard_screen.dart';
import 'product_detail_screen.dart';

class BikeSearchScreen extends StatefulWidget {
  const BikeSearchScreen({super.key});

  @override
  State<BikeSearchScreen> createState() => _BikeSearchScreenState();
}

class _BikeSearchScreenState extends State<BikeSearchScreen> {
  List<dynamic> products = [];
  List<dynamic> categories = [];
  String? selectedCategoryId;
  String searchQuery = "";
  bool isLoading = true;

  double? minPrice;
  double? maxPrice;
  String? sort;
  int page = 1;
  int limit = 6;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final cats = await ApiService.getCategories();
      setState(() {
        categories = List<dynamic>.from(cats);
        // Add an "All" category manually if not in API
        if (!categories.any((c) => c['name'] == 'All')) {
          categories.insert(0, {'id': '', 'name': 'All'});
        }
      });
      _fetchProducts();
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getProducts(
        categoryId: (selectedCategoryId == null || selectedCategoryId!.isEmpty)
            ? null
            : selectedCategoryId,
        search: searchQuery.isEmpty ? null : searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: sort,
        page: page,
        limit: limit,
      );
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching bikes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A121F), // Dark purple background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("BIG BIKE",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService().itemsNotifier,
            builder: (context, items, _) {
              final int totalItems =
                  items.fold(0, (sum, item) => sum + item.quantity);
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddToCardScreen()),
                      );
                    },
                  ),
                  if (totalItems > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchRow(),
            const SizedBox(height: 20),
            _buildCategoryList(),
            const SizedBox(height: 10),
            Text("${products.length} results",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.purple))
                  : _buildProductList(),
            ),
          ],
        ),
      ),
    );
  }

  // SEARCH BAR & FILTER ICON
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF2D2433),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.5)),
            ),
            child: TextField(
              style: TextStyle(color: Colors.white),
              onChanged: (val) {
                searchQuery = val;
                _fetchProducts(); // Real-time search
              },
              decoration: InputDecoration(
                hintText: "Search bikes, models...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _showFilterBottomSheet,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2433),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    TextEditingController minCtrl =
        TextEditingController(text: minPrice?.toString() ?? '');
    TextEditingController maxCtrl =
        TextEditingController(text: maxPrice?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF251C2B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filters",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Min Price",
                              labelStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF2D2433),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: maxCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Max Price",
                              labelStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF2D2433),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: sort,
                      dropdownColor: const Color(0xFF2D2433),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Sort By",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF2D2433),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("None")),
                        DropdownMenuItem(
                            value: "price_asc",
                            child: Text("Price: Low to High")),
                        DropdownMenuItem(
                            value: "price_desc",
                            child: Text("Price: High to Low")),
                      ],
                      onChanged: (val) => setModalState(() => sort = val),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            minPrice = double.tryParse(minCtrl.text);
                            maxPrice = double.tryParse(maxCtrl.text);
                          });
                          Navigator.pop(ctx);
                          _fetchProducts();
                        },
                        child: const Text("Apply Filters",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // CATEGORY HORIZONTAL LIST
  Widget _buildCategoryList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          String catId = cat['id']?.toString() ?? cat['_id']?.toString() ?? '';
          bool isSelected = (selectedCategoryId ?? '') == catId;
          return GestureDetector(
            onTap: () {
              setState(() => selectedCategoryId = catId.isEmpty ? null : catId);
              _fetchProducts();
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey[700] : Color(0xFF2D2433),
                borderRadius: BorderRadius.circular(20),
                border:
                    isSelected ? Border.all(color: Colors.greenAccent) : null,
              ),
              child: Text(
                cat['name'] ?? '',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }

  // BIKE CARDS
  Widget _buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final bike = products[index];

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
            final id = bike['_id']?.toString() ?? bike['id']?.toString() ?? '';
            if (id.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(
                      productId: id, initialData: bike as Map<String, dynamic>),
                ),
              );
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF251C2B),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(bike['description'] ?? "2026 Edition",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(categoryName,
                            style: TextStyle(
                                color: Colors.purpleAccent, fontSize: 10)),
                      ),
                      const SizedBox(height: 8),
                      Text("\$${bike['price'] ?? ''}",
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: WishlistService().itemsNotifier,
                  builder: (context, wishlistItems, _) {
                    final String bikeId =
                        bike['_id']?.toString() ?? bike['id']?.toString() ?? '';
                    final bool isSaved = WishlistService().isSaved(bikeId);

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            WishlistService()
                                .toggleWishlist(bike as Map<String, dynamic>);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isSaved
                                    ? '${bike['name']} removed from wishlist'
                                    : '${bike['name']} saved to wishlist!'),
                                backgroundColor: const Color(0xFF7B5A96),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.redAccent : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            final priceStr = bike['price']?.toString() ?? '0';
                            final doublePrice =
                                double.tryParse(priceStr) ?? 0.0;
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
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: const Icon(Icons.shopping_cart_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
