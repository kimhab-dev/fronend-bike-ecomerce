import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class BikeSearchScreen extends StatefulWidget {
  @override
  _BikeSearchScreenState createState() => _BikeSearchScreenState();
}

class _BikeSearchScreenState extends State<BikeSearchScreen> {
  List<dynamic> products = [];
  List<dynamic> categories = [];
  String? selectedCategoryId;
  String searchQuery = "";
  bool isLoading = true;

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
          IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () {}),
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
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF2D2433),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.tune, color: Colors.white),
        )
      ],
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
                Column(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.grey),
                    const SizedBox(height: 15),
                    CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: Icon(Icons.shopping_cart_outlined,
                          color: Colors.white, size: 20),
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
