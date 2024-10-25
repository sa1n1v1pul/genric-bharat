// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/modules/location/controller/location_controller.dart';
import '../../routes/app_routes.dart';

class LocationView extends StatelessWidget {
  const LocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationController locationController =
        Get.find<LocationController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 55, left: 45, right: 45),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/location_png.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
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

                                await locationController
                                    .handleLocationRequest();
                                Get.toNamed(Routes.HOME);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                minimumSize: const Size(250, 35),
                                padding: EdgeInsets.zero,
                              ),
                              child: locationController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.my_location,
                                          color: Colors.white,
                                          size: 18,
                                        ),
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
      ),
    );
  }
}
