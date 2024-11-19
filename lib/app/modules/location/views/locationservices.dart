import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../controller/location_controller.dart';

class LocationView extends StatelessWidget {
  const LocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find<LocationController>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/3dmap.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Obx(() => SizedBox(
                    height: 35,
                    width: 250,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xffE15564),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          await locationController.handleLocationRequest();
                          Get.toNamed(Routes.HOME);
                        },
                        child: locationController.isLoading.value
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.my_location, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Your current location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontFamily: 'WorkSansBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  TextButton(
                    onPressed: () {
                      locationController.setLocationSkipped();
                      Get.toNamed(Routes.HOME);
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xffE15564),
                        fontSize: 18.0,
                        fontFamily: 'WorkSansBold',
                      ),
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