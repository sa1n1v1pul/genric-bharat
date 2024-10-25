import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/core/theme/theme.dart';

class OffersViews extends StatelessWidget {
  const OffersViews({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: const Text(
          'Best Offers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            _buildCleaningTile(
              'Bathroom and Kitchen Cleaning',
              'assets/images/temp1.png',
            ),
            _buildCleaningTile(
              'Full Home Cleaning',
              'assets/images/temp1.png',
            ),
            _buildCleaningTile(
              'Sofa & Carpet Cleaning',
              'assets/images/temp1.png',
            ),
            _buildCleaningTile(
              'Disinfection Services',
              'assets/images/temp1.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleaningTile(String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      elevation: 4, // Increase elevation for shadow effect
      shadowColor: Colors.grey.withOpacity(0.5),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
