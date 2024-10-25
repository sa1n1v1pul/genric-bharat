import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/modules/widgets/service_Explore.dart';
import '../home/controller/homecontroller.dart';

class AllServices extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

  AllServices({Key? key}) : super(key: key);

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
                padding: EdgeInsets.zero,
              ),
            );
          },
        ),
        toolbarHeight: 80,
        title: const Text(
          'Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeController.categories.isEmpty) {
          return const Center(child: Text('No services available'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: homeController.categories.length,
          itemBuilder: (context, index) {
            final category = homeController.categories[index];
            return InkWell(
              onTap: () {
                homeController.fetchSubcategories(category['id'].toString());
                Get.to(() => ServiceExplore(
                      categoryId: category['id'].toString(),
                      categoryTitle: category['title'] ?? 'Unknown Service',
                    ));
              },
              child: _buildServiceItem(
                category['image'] ?? 'assets/images/temp1.png',
                category['title'] ?? 'Unknown Service',
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildServiceItem(String imagePath, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
                onError: (error, stackTrace) =>
                    const AssetImage('assets/images/temp1.png'),
              ),
            ),
            width: 120,
            height: 100,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
