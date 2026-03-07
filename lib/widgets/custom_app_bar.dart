import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../screens/addToCard_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          children: [
            TextSpan(text: "HAB ", style: TextStyle(color: Colors.white)),
            TextSpan(
              text: "MOTO",
              style: TextStyle(color: Color(0xFFBB86FC)),
            ),
          ],
        ),
      ),
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
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddToCardScreen(),
                      ),
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
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
