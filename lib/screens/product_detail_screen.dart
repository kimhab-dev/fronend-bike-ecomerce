import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic>? initialData;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialData,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>> productFuture;
  late Future<List<dynamic>> productsFuture;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      productFuture = Future.value(widget.initialData!);
    } else {
      productFuture = ApiService.getProductById(widget.productId);
    }
    // Fetch products for "You May Also Like"
    productsFuture = ApiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF120C17),
            body: Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent)),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Color(0xFF120C17),
            body: Center(
                child: Text('Error loading product',
                    style: TextStyle(color: Colors.red))),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF120C17),
            body: Center(
                child: Text('Product not found',
                    style: TextStyle(color: Colors.grey))),
          );
        }

        final product = snapshot.data!;
        final String name = product['name'] ?? '';
        final String price = "\$${product['price']?.toString() ?? ''}";
        final String mainImageUrl =
            product['image'] ?? product['image_url'] ?? '';
        final String description = product['description'] ?? '';

        // Safely extract multiple images if they exist
        List<String> images = [];
        if (product['images'] != null && product['images'] is List) {
          for (var item in product['images']) {
            if (item is String) {
              images.add(item);
            } else if (item is Map) {
              final imgUrl = item['image'] ??
                  item['url'] ??
                  item['image_url'] ??
                  item['imageUrl'];
              if (imgUrl != null && imgUrl is String) images.add(imgUrl);
            }
          }
        }
        if (images.isEmpty && mainImageUrl.isNotEmpty) {
          images.add(mainImageUrl);
        }

        final specs = product['technicalSpecs'] as Map?;
        final String engine = specs?['engineType']?.toString() ??
            product['engine']?.toString() ??
            '';
        final String power = specs?['maxPower']?.toString() ??
            product['power']?.toString() ??
            '';
        final String torque = specs?['maxTorque']?.toString() ??
            product['torque']?.toString() ??
            '';
        final String speed = product['topSpeed']?.toString() ??
            product['top_speed']?.toString() ??
            '';
        final String weight = specs?['dryWeight']?.toString() ??
            product['weight']?.toString() ??
            '';

        return Scaffold(
          backgroundColor: const Color(0xFF120C17),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(context, images),
                    _buildMainDetails(name, price, description),
                    _buildSpecGrid(power, speed, weight, torque),
                    _buildTechnicalSection(
                        engine, power, torque, speed, weight),
                    _buildRecommendations(),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
              _buildBottomActionButtons(),
            ],
          ),
        );
      },
    );
  }

  // 1. Top Image Carousel with Back and Favorite buttons
  Widget _buildImageCarousel(BuildContext context, List<String> images) {
    if (images.isEmpty) {
      return Container(height: 350, color: Colors.grey[900]);
    }

    // Format URLs correctly relative to baseUrl
    final List<String> formattedUrls = images.map((url) {
      if (url.isNotEmpty && !url.startsWith('http')) {
        return ApiService.baseUrl + "/" + url;
      }
      return url;
    }).toList();

    return Stack(
      children: [
        SizedBox(
          height: 350,
          width: double.infinity,
          child: formattedUrls.length == 1
              ? Image.network(formattedUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[900]))
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                          height: 350,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: formattedUrls.length > 1,
                          autoPlay: formattedUrls.length > 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          }),
                      items: formattedUrls.map<Widget>((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      Container(color: Colors.grey[900])),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Positioned(
                      bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: formattedUrls.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.white)
                                    .withOpacity(_currentImageIndex == entry.key
                                        ? 0.9
                                        : 0.4)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.white),
                        onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.white),
                        onPressed: () {}),
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFF8E244D),
                borderRadius: BorderRadius.circular(20)),
            child: const Text("Featured",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  // 2. Title and Description
  Widget _buildMainDetails(String name, String price, String desc) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    const Text("2026 Superbike",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Price",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(price,
                      style: const TextStyle(
                          color: Color(0xFF90EE90),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white10, borderRadius: BorderRadius.circular(15)),
            child: const Text("Superbike",
                style: TextStyle(color: Color(0xFF90EE90), fontSize: 12)),
          ),
          const SizedBox(height: 20),
          Text(desc,
              style: const TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }

  // 3. Grid of Spec Cards (Translucent)
  Widget _buildSpecGrid(
      String power, String speed, String weight, String torque) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.6,
        children: [
          if (power.isNotEmpty) _specCard(Icons.bolt, "Power", power),
          if (speed.isNotEmpty) _specCard(Icons.speed, "Top Speed", speed),
          if (weight.isNotEmpty)
            _specCard(Icons.fitness_center, "Weight", weight),
          if (torque.isNotEmpty) _specCard(Icons.air, "Torque", torque),
        ],
      ),
    );
  }

  Widget _specCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 4. Detailed Technical Table
  Widget _buildTechnicalSection(
      String engine, String power, String torque, String speed, String weight) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Technical Specifications",
              style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (engine.isNotEmpty) _techRow("Engine Type", engine),
          if (power.isNotEmpty) _techRow("Max Power", power),
          if (torque.isNotEmpty) _techRow("Max Torque", torque),
          if (speed.isNotEmpty) _techRow("Top Speed", speed),
          if (weight.isNotEmpty) _techRow("Dry Weight", weight),
        ],
      ),
    );
  }

  Widget _techRow(String key, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Expanded(
            child: Text(val,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // 5. "You May Also Like" Horizontal List (Fetching from API)
  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("You May Also Like",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 250, // Increased height to match card
          child: FutureBuilder<List<dynamic>>(
            future: productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No recommendations available",
                      style: TextStyle(color: Colors.grey)),
                );
              }

              final List<dynamic> allProducts = snapshot.data!;
              // Filter out the current product from recommendations
              final List<dynamic> recommendations = allProducts.where((p) {
                final id = p['_id']?.toString() ?? p['id']?.toString() ?? '';
                return id != widget.productId;
              }).toList();

              // Only show up to 5 recommendations to keep it clean
              final List<dynamic> limitedRecs =
                  recommendations.take(5).toList();

              if (limitedRecs.isEmpty) {
                return const Center(
                  child: Text("No recommendations available",
                      style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: limitedRecs.length,
                itemBuilder: (context, index) {
                  final product = limitedRecs[index];

                  String rawImage = product['image'] ??
                      product['image_url'] ??
                      product['imageUrl'] ??
                      '';
                  String imageUrl = rawImage;
                  if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
                    imageUrl = ApiService.baseUrl + "/" + rawImage;
                  }

                  String categoryName = '';
                  if (product['category'] != null) {
                    final cat = product['category'];
                    if (cat is Map && cat['name'] != null) {
                      categoryName = cat['name'].toString();
                    }
                  }

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
                                initialData: product as Map<String, dynamic>),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 170, // Fixed width for horizontal list
                      margin: const EdgeInsets.only(right: 15),
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Shared bike card UI adapted from product_list_screen
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
                child: SizedBox(
                  height: 120, // Slightly shorter than list view
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.black26,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white24, size: 40),
                          ),
                        ),
                ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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

  // 6. Floating Action Buttons (Add to Cart / Buy Now)
  Widget _buildBottomActionButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
        )),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5A8C),
                      Color(0xFF7CB670),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  onPressed: () {},
                  child: const Text("Add to Cart",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E244D),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                onPressed: () {},
                child: const Text("Buy Now",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
