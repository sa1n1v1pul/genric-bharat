import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../routes/app_routes.dart';
import '../controller/profile_controller.dart';

class VlogsListScreen extends GetView<ProfileController> {
  const VlogsListScreen({Key? key, this.fromBottomNav = false})
      : super(key: key);

  final bool fromBottomNav;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    // Fetch vlogs if not already loaded or if coming from bottom nav
    if (controller.vlogsList.isEmpty || fromBottomNav) {
      controller.fetchVlogs();
    }

    final bool isDarkMode = Get.isDarkMode ?? false;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey[300] : Colors.grey[600];

    return Scaffold(
      backgroundColor: fromBottomNav
          ? CustomTheme.backgroundColor
          : (isDarkMode ? Colors.black45 : Colors.white),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: textColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        leading: fromBottomNav
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                color: textColor,
                onPressed: () => Get.back(),
              ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Blogs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.isVlogsLoading.value
            ? Center(
                child: CircularProgressIndicator(
                color:
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
              ))
            : controller.vlogsList.isEmpty
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'No blogs found',
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.vlogsList.length,
                    itemBuilder: (context, index) {
                      final vlog = controller.vlogsList[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.blueGrey
                                : CustomTheme.loginGradientStart
                                    .withOpacity(0.4),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  child: Image.network(
                                    vlog['photo'],
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: 180,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.error,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.grey[700]),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title now appears separately with more prominence
                                    Text(
                                      vlog['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // Posted date appears below the title
                                    Text(
                                      'Posted on: ${vlog['created_at']?.toString().split('T')[0] ?? ''}',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Category: ${vlog['category']?['name'] ?? ''}',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Read More',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            isDarkMode ? Colors.black45 : CustomTheme.backgroundColor,
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
          'Blog Details',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
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
