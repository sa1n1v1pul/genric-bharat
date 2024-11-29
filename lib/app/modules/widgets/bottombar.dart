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
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BottomAppBar(
      height: 63 + bottomPadding,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem(context, FontAwesome.cart_plus, 'Cart', 0, primaryColor)),
            Expanded(child: _buildNavItem(context, FontAwesome.rupee, 'Refer & Earn', 1, primaryColor)),
            const SizedBox(width: 30), // Space for FAB
            Expanded(child: _buildNavItem(context, FontAwesome.gift, 'Orders', 3, primaryColor)),
            Expanded(child: _buildNavItem(context, FontAwesome.user, 'Account', 4, primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, Color primaryColor) {
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected ? primaryColor : Colors.grey;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

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
              size: 18,
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
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10 / textScaleFactor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
