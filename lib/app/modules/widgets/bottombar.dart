// bottom_nav_bar.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return BottomAppBar(
      height: 63,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              context, FontAwesome.cart_plus, 'Cart', 0, primaryColor),
          _buildNavItem(
              context, FontAwesome.rupee, 'Refer & Earn', 1, primaryColor),
          const SizedBox(width: 30), // Space for FAB
          _buildNavItem(
              context, FontAwesome.gift, 'My Orders', 3, primaryColor),
          _buildNavItem(context, FontAwesome.user, 'Account', 4, primaryColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      int index, Color primaryColor) {
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected ? primaryColor : Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onItemTapped(index),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20, // Reduced icon size
            ).animate(target: isSelected ? 1 : 0).custom(
                  duration: 300.ms,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(
                      4 * sin(value * 2 * 3.14159),
                      isSelected ? 2 * sin(value * 4 * 3.14159) : 0,
                    ),
                    child: child,
                  ),
                ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12, // Smaller text size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
