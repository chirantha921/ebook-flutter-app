import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.explore_outlined, 'label': 'Discover'},
      {'icon': Icons.bookmark_outline, 'label': 'Wishlist'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      height: 65, // Reduced height
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 50, // Fixed width for each item
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7E21),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(6), // Reduced padding
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF7E21) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          items[index]['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 20, // Reduced icon size
                        ),
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 11, // Reduced font size
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFFF7E21) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}