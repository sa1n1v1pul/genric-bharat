import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../api_endpoints/api_provider.dart';

class LocationController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxString currentAddress = RxString('');
  final RxBool isLoading = RxBool(false);
  final RxBool isLocationSkipped = RxBool(false);
  final RxBool isPermissionDenied = RxBool(false);
  Timer? _debounceTimer;
  final RxBool recentlyUpdatedViaButton = RxBool(false);
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final Completer<GoogleMapController> mapController = Completer();
  final RxString cityName = RxString('Loading...');
  final RxString stateName = RxString('');

  @override
  void onInit() {
    super.onInit();
    print("LocationController initialized");
    loadLastKnownLocation();
    Future.delayed(Duration(seconds: 25), () {
      getCurrentLocation();
    });
  }

  @override
  void onClose() {
    print("LocationController onClose called");
    _debounceTimer?.cancel();
    super.onClose();
  }

  void updateLocation(double latitude, double longitude, String address) {
    currentPosition.value = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    currentAddress.value = address;

    // Update city and state names
    getAddressFromLatLng(currentPosition.value!);

    // Save the new location
    saveLastKnownLocation();

    // Print the updated location to the debug console
    print(
        "LocationController Updated: Latitude - $latitude, Longitude - $longitude");
  }

  Future<void> loadLastKnownLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble('last_latitude');
    double? lng = prefs.getDouble('last_longitude');
    String? lastAddress = prefs.getString('last_address');
    String? lastCityName = prefs.getString('last_city_name');
    String? lastStateName = prefs.getString('last_state_name');

    if (lat != null && lng != null) {
      currentPosition.value = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      currentAddress.value = lastAddress ?? '';
      cityName.value = lastCityName ?? '';
      stateName.value = lastStateName ?? '';
    }
  }

  Future<void> saveLastKnownLocation() async {
    if (currentPosition.value != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setDouble('last_latitude', currentPosition.value!.latitude);
      prefs.setDouble('last_longitude', currentPosition.value!.longitude);
      prefs.setString('last_address', currentAddress.value);
      prefs.setString('last_city_name', cityName.value);
      prefs.setString('last_state_name', stateName.value);
    }
  }

  Future<void> requestPermissionAndGetLocation() async {
    try {
      isLoading.value = true;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permissions are denied',
            colorText: Colors.black,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Location permissions are permanently denied. Please enable them in your app settings.',
          colorText: Colors.black,
        );
        return;
      }

      await getCurrentLocation();
    } catch (e) {
      print('Error in requestPermissionAndGetLocation: $e');
      Get.snackbar(
        'Error',
        'An error occurred while requesting location permission',
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAddressFromLatLng(Position position) async {
    try {
      print("Executing getAddressFromLatLng");
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String localityName = place.subLocality?.isNotEmpty == true
            ? place.subLocality!
            : (place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea?.isNotEmpty == true
            ? place.subAdministrativeArea!
            : 'Unknown Location'));

        String city = place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea?.isNotEmpty == true
            ? place.subAdministrativeArea!
            : 'Unknown City');

        stateName.value = place.administrativeArea ?? 'Unknown State';

        if (localityName == city) {
          cityName.value = "$localityName, ${stateName.value}".toUpperCase();
        } else {
          cityName.value =
              "$localityName ($city), ${stateName.value}".toUpperCase();
        }

        currentAddress.value =
        "${place.street}, $localityName, $city, ${stateName.value}";

        // Save the new location
        saveLastKnownLocation();
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
      currentAddress.value =
      '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      cityName.value = 'Location Unavailable';
      stateName.value = '';
    }
  }

  Future<void> updateLocationFromHomepage() async {
    bool locationUpdated = await handleLocationRequest();
    if (locationUpdated) {
      await updateLocationInDatabase();
      Get.snackbar(
          'Location Updated', 'Your location has been successfully updated.');
    }
  }

  Future<bool> handleLocationRequest() async {
    try {
      isLoading.value = true;
      isLocationSkipped.value = false;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Services Disabled',
          'Please enable location services in your device settings.',
          colorText: Colors.black,
        );
        isPermissionDenied.value = true;
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permissions are denied',
            colorText: Colors.black,
          );
          isPermissionDenied.value = true;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Location permissions are permanently denied. Please enable them in your app settings.',
          colorText: Colors.black,
        );
        isPermissionDenied.value = true;
        return false;
      }

      isPermissionDenied.value = false;
      await getCurrentLocation();

      // After getting the location, update it in the database
      await updateLocationInDatabase();

      recentlyUpdatedViaButton.value = true;
      return true;
    } catch (e) {
      print('Error in handleLocationRequest: $e');
      Get.snackbar(
        'Error',
        'An error occurred while handling location request',
        colorText: Colors.black,
      );
      isPermissionDenied.value = true;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLocationInDatabase() async {
    if (currentPosition.value != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id');
        if (userId == null) {
          print('User ID not found');
          return;
        }

        final response = await apiProvider.updateUserLocation(
          userId,
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
        );

        if (response.statusCode == 200) {
          print('Location updated successfully in the database');
        } else {
          print('Failed to update location in the database');
        }
      } catch (e) {
        print('Error updating location in the database: $e');
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition.value = position;

      print(
          "Current Location: Latitude - ${position.latitude}, Longitude - ${position.longitude}");

      await getAddressFromLatLng(position);
      await updateLocationInDatabase();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void setLocationSkipped() {
    isLocationSkipped.value = true;
    isPermissionDenied.value = false;
    currentAddress.value = 'Location Skipped';
    cityName.value = 'Location Skipped';
  }

  Future<void> openMap() async {
    final GoogleMapController controller = await mapController.future;
    if (currentPosition.value != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentPosition.value!.latitude,
              currentPosition.value!.longitude),
          zoom: 14.0,
        ),
      ));
    }
  }

  Future<void> updateSelectedLocation(LatLng location) async {
    selectedLocation.value = location;
    List<Placemark> placemarks =
    await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];

      String localityName = place.subLocality?.isNotEmpty == true
          ? place.subLocality!
          : (place.locality?.isNotEmpty == true
          ? place.locality!
          : (place.subAdministrativeArea?.isNotEmpty == true
          ? place.subAdministrativeArea!
          : 'Unknown Location'));

      String city = place.locality?.isNotEmpty == true
          ? place.locality!
          : (place.subAdministrativeArea?.isNotEmpty == true
          ? place.subAdministrativeArea!
          : 'Unknown City');

      stateName.value = place.administrativeArea ?? 'Unknown State';

      if (localityName == city) {
        cityName.value = "$localityName, ${stateName.value}".toUpperCase();
      } else {
        cityName.value =
            "$localityName ($city), ${stateName.value}".toUpperCase();
      }

      currentAddress.value =
      "${place.street}, $localityName, $city, ${stateName.value}";
    }

    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(location));
  }
}

Future<bool> isLocationPermissionGranted() async {
  LocationPermission permission = await Geolocator.checkPermission();
  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}