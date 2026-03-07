import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import 'profile_user_screen.dart';
import 'product_search_screen.dart';
import 'product_save_screen.dart';
import '../services/wishlist_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    ProductListScreen(onSearchTap: () {
      if (mounted) setState(() => _currentIndex = 1);
    }), // Home (Your bike list)
    BikeSearchScreen(),
    const ProductSaveScreen(), // Saved (Wishlist)
    const ProfileUserScreen(), // Profile (User info)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A121F), // Dark background matching the app
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, "Home"),
          _buildNavItem(1, Icons.search, "Search"),
          _buildNavItem(2, Icons.favorite_border, "Saved", isSavedTab: true),
          _buildNavItem(3, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      {bool isSavedTab = false}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Colors.white : Colors.grey[500]!;

    Widget iconWidget = Icon(icon, color: color, size: 26);

    if (isSavedTab) {
      iconWidget = ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: WishlistService().itemsNotifier,
        builder: (context, items, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 26),
              if (items.isNotEmpty)
                Positioned(
                  top: -2,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB03A48), // Badge color
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      items.length.toString(),
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
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF8B5A8C).withOpacity(0.8),
                        const Color(0xFF7CB670).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: iconWidget,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
