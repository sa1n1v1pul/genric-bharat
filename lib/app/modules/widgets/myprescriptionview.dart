import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';
import '../prescription/controller/prescriptioncontroller.dart';

class PrescriptionListScreen extends GetView<PrescriptionController> {
  const PrescriptionListScreen({Key? key}) : super(key: key);
  static String get route => '/prescription-list';
  String formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

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
          'My Prescriptions',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),

      body: Obx(
            () => controller.isPrescriptionsLoading.value
            ? Center(child: CircularProgressIndicator())
            : controller.prescriptions.isEmpty
            ? Center(child: Text('No prescriptions found'))
            : ListView.builder(
          itemCount: controller.prescriptions.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final prescription = controller.prescriptions[index];
            final date = formatDate(prescription['created_at']?.toString());
            final imageUrl = prescription['prescription_url']?.toString() ?? '';
            final id = prescription['id']?.toString() ?? '';
            if (imageUrl.isEmpty) {
              return SizedBox(); // Skip if no image URL
            }
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => Get.to(() => PrescriptionPreviewScreen(
                  imageUrl: imageUrl,
                  date: date,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prescription #$id',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
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

class PrescriptionPreviewScreen extends StatelessWidget {
  final String imageUrl;
  final String date;

  const PrescriptionPreviewScreen({
    Key? key,
    required this.imageUrl,
    required this.date,
  }) : super(key: key);

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
          '$date',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),

      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text('Error loading image'),
              );
            },
          ),
        ),
      ),
    );
  }
}