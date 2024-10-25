import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/controller/homecontroller.dart';
import 'workerdash.dart';

class ProviderListScreen extends StatefulWidget {
  final String serviceId;
  final String userId;

  ProviderListScreen({required this.serviceId, required this.userId});

  @override
  _ProviderListScreenState createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    homeController.fetchProviders(widget.serviceId, widget.userId);
  }

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
          'All Providers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        if (homeController.isProvidersLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: homeController.providers.length,
          itemBuilder: (context, index) {
            final provider = homeController.providers[index];
            return ProviderCard(
              name: provider['name'] ?? '',
              imageUrl: provider['image'] ?? '',
              onTap: () {
                Get.to(() => WorkerDash());
              },
            );
          },
        );
      }),
    );
  }
}

class ProviderCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const ProviderCard({
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          height: 80,
          child: Center(
            child: ListTile(
              leading: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 60,
                      );
                    },
                  ),
                ),
              ),
              title: Text(name),
            ),
          ),
        ),
      ),
    );
  }
}
