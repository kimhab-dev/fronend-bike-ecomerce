import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      productFuture = Future.value(widget.initialData!);
    } else {
      productFuture = ApiService.getProductById(widget.productId);
    }
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
          return Scaffold(
            backgroundColor: const Color(0xFF120C17),
            body: Center(
                child: Text('Error loading product',
                    style: const TextStyle(color: Colors.red))),
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
        final String imageUrl = product['image'] ?? product['image_url'] ?? '';
        final String description = product['description'] ?? '';

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
                    _buildImageHeader(context, imageUrl),
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

  // 1. Top Image with Back and Favorite buttons
  Widget _buildImageHeader(BuildContext context, String imageUrl) {
    return Stack(
      children: [
        SizedBox(
          height: 350,
          width: double.infinity,
          child: Image.network(imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[900])),
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
              Column(
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
          _specCard(Icons.bolt, "Power", power),
          _specCard(Icons.speed, "Top Speed", speed),
          _specCard(Icons.fitness_center, "Weight", weight),
          _specCard(Icons.air, "Torque", torque),
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
          _techRow("Engine Type", engine),
          _techRow("Max Power", power),
          _techRow("Max Torque", torque),
          _techRow("Top Speed", speed),
          _techRow("Dry Weight", weight),
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
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 5. "You May Also Like" Horizontal List
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
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            children: [
              _recCard("Phantom X1", "\$24,999"),
              _recCard("Shadow Racer", "\$32,999"),
            ],
          ),
        )
      ],
    );
  }

  Widget _recCard(String name, String price) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
                height: 100,
                color: Colors.white10), // Replace with Image.network
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(price,
                    style: const TextStyle(
                        color: Color(0xFF90EE90), fontSize: 12)),
              ],
            ),
          )
        ],
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.white24))),
                onPressed: () {},
                child: const Text("Add to Cart",
                    style: TextStyle(color: Colors.white)),
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
