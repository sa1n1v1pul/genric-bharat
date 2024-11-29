import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../core/theme/theme.dart';
import '../home/controller/homecontroller.dart';

class DynamicPageScreen extends StatelessWidget {
  final String title;
  final String slug;

  const DynamicPageScreen({
    Key? key,
    required this.title,
    required this.slug
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the HomeController
    final HomeController controller = Get.find<HomeController>();

    // Fetch page content when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPageContent(slug);
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black45 : CustomTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(title),
      ),
      body: Obx(() {
        // Show loading indicator while content is being fetched
        if (controller.isPageLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Display the page content using Html widget for rich text rendering
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Html(
            data: controller.pageContent.value,
            style: {
              'body': Style(
                fontSize: FontSize(16),
                lineHeight: LineHeight(1.5),
              ),
            },
          ),
        );
      }),
    );
  }
}