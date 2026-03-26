import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart'; // Ensure this path is correct
import '../services/cart_service.dart';

import 'product_detail_screen.dart'; // Needed for navigation to details
import 'product_search_screen.dart';
import '../widgets/custom_app_bar.dart';

class ProductListScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
  const ProductListScreen({super.key, this.onSearchTap});

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
    // Remove internal products and search logic from init state
    categories = ApiService.getCategories();
    products = ApiService.getProducts(limit: 6, page: 1, sort: "price_desc");
    selectedCategoryId = null; // start unfiltered
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120C17), // Deep Dark Purple
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const SizedBox(height: 30),
                _buildHeroText(),
                const SizedBox(height: 25),
                _buildImageSwiper(),
                const SizedBox(height: 25),
                _buildSearchBar(),
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
                            price: product['price']?.toString() ?? '',
                            imageUrl: imageUrl,
                            category: categoryName,
                            onAddCart: () {
                              final priceStr =
                                  product['price']?.toString() ?? '0';
                              final doublePrice =
                                  double.tryParse(priceStr) ?? 0.0;
                              CartService().addToCart(CartItem(
                                id: product['_id']?.toString() ??
                                    product['id']?.toString() ??
                                    DateTime.now().toString(),
                                name: product['name'] ?? 'Unknown Bike',
                                edition: categoryName.isNotEmpty
                                    ? categoryName
                                    : 'Standard Edition',
                                price: doublePrice,
                                imageUrl: imageUrl,
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product['name']} added to cart!'),
                                  backgroundColor: const Color(0xFF7B5A96),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
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
    return GestureDetector(
      onTap: () {
        if (widget.onSearchTap != null) {
          widget.onSearchTap!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BikeSearchScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const TextField(
          enabled: false,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            hintText: "Search bikes...",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSwiper() {
    final List<String> imgList = [
      'https://imgd.aeplcdn.com/664x374/n/cw/ec/195355/s1000rr-side-fairing.jpeg?isig=0&q=80',
      'https://cdn.visordown.com/2024-09/Kawasaki%20Ninja%20H2R.JPG?width=900&format=webp&aspect_ratio=16:9',
      'https://images.ctfassets.net/x7j9qwvpvr5s/43adRuY33iuCayAyMy3wTw/5545b174f876fc95ffcfff3d643c4d23/Ducati-MY25-Panigale-V4-overview-carousel-hero-link-1600x650-01.jpg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.85,
      ),
      items: imgList
          .map((item) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ))
          .toList(),
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
    required String imageUrl,
    required String category,
    required VoidCallback onAddCart,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1625),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5A8C), Color(0xFF7CB670)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text("NEW",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.isNotEmpty) ...[
                        Text(category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.purpleAccent.withOpacity(0.8),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                      ],
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(type.isNotEmpty ? type : 'Top Speed: N/A',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$$price",
                          style: const TextStyle(
                              color: Color(0xFF00FFCC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                      GestureDetector(
                        onTap: onAddCart,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5A8C), Color(0xFF7CB670)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7CB670).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: const Icon(Icons.add_shopping_cart,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
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
      width: double.infinity,
      height: double.infinity,
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
}
