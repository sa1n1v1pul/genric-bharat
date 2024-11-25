import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';
import '../controller/profile_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VlogsListScreen extends GetView<ProfileController> {
  const VlogsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Blogs',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Obx(
            () => controller.isVlogsLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.vlogsList.length,
          itemBuilder: (context, index) {
            final vlog = controller.vlogsList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  controller.setSelectedVlog(vlog);
                  Get.toNamed(Routes.VLOG_DETAILS);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vlog['photo'] != null)
                      Image.network(
                        vlog['photo'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vlog['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vlog['category']?['name'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted on: ${vlog['created_at']?.toString().split('T')[0] ?? ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Read More',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).primaryColor,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class VlogDetailsScreen extends GetView<ProfileController> {
  const VlogDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black45 : CustomTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Blog Details',
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black
          ),
        ),
      ),
      body: Obx(
            () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.selectedVlog.value['photo'] != null)
                Image.network(
                  controller.selectedVlog.value['photo'],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.selectedVlog.value['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${controller.selectedVlog.value['category']?['name'] ?? ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Posted on: ${controller.selectedVlog.value['created_at']?.toString().split('T')[0] ?? ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.processVlogContent(
                        controller.selectedVlog.value['details'] ?? '',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}