// medical_devices_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/theme.dart';
import '../api_endpoints/api_endpoints.dart';
import '../cart/controller/cartcontroller.dart';
import '../cart/view/cartscreen.dart';
import '../home/controller/homecontroller.dart';
import 'medicinedetailsheet.dart';

class MedicalDevicesScreen extends StatelessWidget {
  const MedicalDevicesScreen({Key? key}) : super(key: key);

  String getCompleteImageUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final CartController cartController = Get.find<CartController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.only(left: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.grey)
                        .withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18 / textScaleFactor,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            );
          },
        ),
        title: Text(
          'Medical Devices',
          style: TextStyle(fontSize: 18 / textScaleFactor, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 60 * textScaleFactor,
      ),
      body: Obx(() {
        final devices = controller.getItemsForCategory("MEDICAL DEVICES");

        return GridView.builder(
          padding: EdgeInsets.all(16 * textScaleFactor),
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65 / textScaleFactor,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            final discount = device['previous_price'] != 0
                ? ((device['previous_price'] - device['discount_price']) /
                device['previous_price'] *
                100)
                .toStringAsFixed(0)
                : '0';

            return _buildDeviceCard(
              context,
              device: device,
              discount: discount,
              isDarkMode: isDarkMode,
              cartController: cartController, textScaleFactor: textScaleFactor,
            );
          },
        );
      }),
    );
  }

  Widget _buildDeviceCard(
      BuildContext context, {
        required Map<String, dynamic> device,
        required String discount,
        required bool isDarkMode,
        required CartController cartController,   required double textScaleFactor,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.6,
              maxChildSize: 0.8,
              builder: (context, scrollController) => MedicineDetailsSheet(
                service: device,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    getCompleteImageUrl(device['photo']),
                    height: 100* textScaleFactor,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180 * textScaleFactor,
                        color: Colors.grey[300],
                        child:  Icon(Icons.error,size: 24 * textScaleFactor),
                      );
                    },
                  ),
                ),
                if (discount != '0')
                  Container(
                    margin:  EdgeInsets.all(8* textScaleFactor),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * textScaleFactor,
                      vertical: 4 * textScaleFactor,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style:  TextStyle(
                        color: Colors.white,
                        fontSize: 12 / textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding:  EdgeInsets.all(12 * textScaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device['name'],
                    style:  TextStyle(
                      fontSize: 14 / textScaleFactor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4 * textScaleFactor),
                  Row(
                    children: [
                      if (device['previous_price'] > 0) ...[
                        Text(
                          '₹${device['previous_price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 11 / textScaleFactor,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '₹${device['discount_price'].toStringAsFixed(2)}',
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12 / textScaleFactor,
                        ),
                      ),
                    ],
                  ),
                 SizedBox(height: 8* textScaleFactor),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cartController.addToCart(device);
                        Get.to(() => const CartScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: CustomTheme.loginGradientStart,
                        backgroundColor: Colors.white,
                        side:  BorderSide(color: CustomTheme.loginGradientStart,),
                        padding:  EdgeInsets.symmetric(vertical: 8 * textScaleFactor),
                      ),
                      child:  Text('Add',  style: TextStyle(fontSize: 14 / textScaleFactor),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}