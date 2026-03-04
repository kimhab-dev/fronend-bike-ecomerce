import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Ensure this path is correct
import 'product_detail_screen.dart'; // Needed for navigation to details

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<dynamic>> products;
  late Future<List<dynamic>> categories;

  /// Tracks the currently selected category ID. `null` means no filter
  /// (i.e. "All"). We're using a string because IDs come back as
  /// Mongo ObjectIds (e.g. "69a5ba3bc2d495f0cf9365ad").
  String? selectedCategoryId;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    // start both requests
    categories = ApiService.getCategories();
    products = ApiService.getProducts();
    selectedCategoryId = null; // start unfiltered
    searchQuery = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120C17), // Deep Dark Purple
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildHeroText(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 25),
                _buildFeatureIcons(),
                const SizedBox(height: 30),
                _buildCategoryTabs(),
                const SizedBox(height: 25),
                const Text(
                  "Featured Bikes",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // --- INTEGRATING YOUR API DATA HERE ---
                FutureBuilder<List<dynamic>>(
                  future: products,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.purpleAccent),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error loading bikes",
                            style: TextStyle(color: Colors.red)),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No bikes found",
                            style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final productList = snapshot.data!;

                    // Display products in a 2-column grid layout
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.65,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        // Determine image URL from whichever key the API uses.
                        // We also prefix with baseUrl if the value is a relative path.
                        String rawImage = product['image'] ??
                            product['image_url'] ??
                            product['imageUrl'] ??
                            '';
                        String imageUrl = rawImage;
                        if (rawImage.isNotEmpty &&
                            !rawImage.startsWith('http')) {
                          // assume server provides path relative to base
                          imageUrl = ApiService.baseUrl + "/" + rawImage;
                        }

                        // determine category name if available
                        String categoryName = '';
                        if (product['category'] != null) {
                          final cat = product['category'];
                          if (cat is Map && cat['name'] != null) {
                            categoryName = cat['name'].toString();
                          }
                        }

                        // Wrap the card in a gesture detector for navigation
                        return GestureDetector(
                          onTap: () {
                            final id = product['_id']?.toString() ??
                                product['id']?.toString() ??
                                '';
                            if (id.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                      productId: id,
                                      initialData:
                                          product as Map<String, dynamic>),
                                ),
                              );
                            }
                          },
                          child: _buildBikeCard(
                            name: product['name'] ?? 'Unknown Bike',
                            type: product['topSpeed'] ?? '',
                            price: "\$${product['price'] ?? ''}",
                            engine: product['technicalSpecs']?['engineType'] ??
                                product['engine'] ??
                                '',
                            power: product['power'] ?? '',
                            imageUrl: imageUrl,
                            category: categoryName,
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: "BIG", style: TextStyle(color: Colors.white)),
                TextSpan(
                    text: "BIKE", style: TextStyle(color: Color(0xFFBB86FC))),
              ],
            ),
          ),
          const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Premium",
            style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold)),
        Text(
          "Motorcycles",
          style: TextStyle(
              color: Colors.greenAccent.withOpacity(0.8),
              fontSize: 36,
              fontWeight: FontWeight.bold),
        ),
        const Text("Experience the thrill of the ride",
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            searchQuery = value.isEmpty ? null : value;
            products = ApiService.getProducts(
              categoryId: selectedCategoryId,
              search: searchQuery,
            );
          });
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search bikes...",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFeatureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _featureBox(Icons.bolt, "Fast"),
        _featureBox(Icons.workspace_premium, "Premium"),
        _featureBox(Icons.shield_outlined, "Safe"),
      ],
    );
  }

  Widget _featureBox(IconData icon, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return FutureBuilder<List<dynamic>>(
      future: categories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            ),
          );
        } else if (snapshot.hasError) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: Text('Error loading categories',
                  style: TextStyle(color: Colors.red)),
            ),
          );
        }

        final catsData = snapshot.data ?? [];
        // Build a list of maps with id & name; prepend null/"All" entry.
        final cats = <Map<String, dynamic>>[
          {'id': null, 'name': 'All'}
        ];
        cats.addAll(catsData.map<Map<String, dynamic>>((c) {
          final rawId = c['id'] ?? c['_id'];
          return {'id': rawId?.toString(), 'name': c['name']?.toString() ?? ''};
        }));

        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              final String? catId = cat['id'] as String?;
              final String catName = cat['name'] as String;
              final bool isSelected = selectedCategoryId == catId;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategoryId = catId;
                    products = ApiService.getProducts(
                      categoryId: catId,
                      search: searchQuery,
                    );
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    catName,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBikeCard({
    required String name,
    required String type,
    required String price,
    required String engine,
    required String power,
    required String imageUrl,
    required String category,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1625),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildProductImage(imageUrl),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text("NEW",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(price,
                      style: const TextStyle(
                          color: Color(0xFF90EE90),
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  if (category.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text("Category: $category",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      children: [
                        _specBoxSmall("Engine", engine),
                        const SizedBox(width: 6),
                        _specBoxSmall("Power", power),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: imageUrl.isEmpty
          ? Container(
              color: Colors.black26,
              child: const Icon(Icons.image_not_supported,
                  color: Colors.white24, size: 40),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Show default image on error
                return Container(
                  color: Colors.black26,
                  child: const Icon(Icons.broken_image,
                      color: Colors.white24, size: 40),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.purpleAccent,
                  ),
                );
              },
            ),
    );
  }

  Widget _specBoxSmall(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 9)),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
