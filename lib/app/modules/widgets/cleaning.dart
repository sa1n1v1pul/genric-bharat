import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllCleaning extends StatelessWidget {
  const AllCleaning({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.grey[550]
          : const Color.fromARGB(255, 244, 243, 248),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode
              ? const Color.fromARGB(255, 244, 243, 248)
              : Colors.black,
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            final ThemeData theme = Theme.of(context);
            final bool isDarkMode = theme.brightness == Brightness.dark;

            return Container(
              padding: const EdgeInsets.only(left: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.white)
                        .withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero, // Remove default padding
              ),
            );
          },
        ),

        toolbarHeight: 80, // Increase the height of the AppBar
        title: const Text(
          'Cleaning',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
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
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4, // Increase elevation for shadow effect
        shadowColor: Colors.grey.withOpacity(0.5), // Add shadow color
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}
