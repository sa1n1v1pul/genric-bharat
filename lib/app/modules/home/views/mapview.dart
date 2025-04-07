import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/constantfile.dart';
import '../../../core/theme/theme.dart';
import '../../api_endpoints/api_provider.dart';
import '../../location/controller/location_controller.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/latlng.dart';

class LocationPage extends StatelessWidget {
  final double lat;
  final double lng;

  LocationPage(this.lat, this.lng);

  @override
  Widget build(BuildContext context) {
    return SetLocatio(lat, lng);
  }
}

class SetLocatio extends StatefulWidget {
  final double lat;
  final double lng;

  SetLocatio(this.lat, this.lng);

  @override
  SetLocationState createState() => SetLocationState(lat, lng);
}

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);

class SetLocationState extends State<SetLocatio> {
  late ApiProvider apiProvider;
  late LocationController locationController;
  dynamic lat;
  dynamic lng;
  CameraPosition? kGooglePlex;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SetLocationState(this.lat, this.lng) {
    kGooglePlex = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.0,
    );
  }
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  bool isCard = false;
  Completer<GoogleMapController> _controller = Completer();

  var isVisible = false;
  bool button = false;

  var currentAddress = '';

  Future<void> handleContinuePressed() async {
    try {
      setState(() {
        isLoading = true;
      });

      await updateLocationInDatabase(lat, lng);

      if (mounted) {
        Navigator.of(context).pop(BackLatLng(lat, lng));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateLocationInDatabase(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        // print('User ID not found');
        return;
      }

      // print('Updating location for user ID: $userId');

      final response = await apiProvider.updateUserLocation(userId, lat, lng);

      if (response.statusCode == 200) {
        // print('Location updated successfully in the database');
      } else {
        // print(
        //     'Failed to update location in the database. Status code: ${response.statusCode}');
        // print('Response body: ${response.data}');
      }
    } catch (e) {
      // print('Error updating location in the database: $e');
    }
  }

  Future<void> _goToTheLake(double lat, double lng) async {
    final CameraPosition _kLake = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.0,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    super.initState();
    apiProvider = Get.find<ApiProvider>();
    setState(() {
      button = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnabled) {
        setState(() {
          isLoading = true;
        });
        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          double lat = position.latitude;
          double lng = position.longitude;
          prefs.setString("lat", lat.toStringAsFixed(8));
          prefs.setString("lng", lng.toStringAsFixed(8));
          GeoData data = await Geocoder2.getDataFromCoordinates(
              latitude: lat, longitude: lng, googleMapApiKey: apiKey);
          setState(() {
            currentAddress = data.address;
            _goToTheLake(lat, lng);
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: 'Error getting location: $e',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white);
        }
      } else {
        _handleLocationServiceDisabled();
      }
    } else {
      _handleLocationPermissionDenied();
    }
  }

  void _handleLocationServiceDisabled() async {
    bool serviceEnabled = await Geolocator.openLocationSettings();
    if (serviceEnabled) {
      _getLocation();
    } else {
      Fluttertoast.showToast(
          msg: 'Location services are required!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  void _handleLocationPermissionDenied() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getLocation();
    } else {
      Fluttertoast.showToast(
          msg: 'Location permission is required!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  void _getCameraMoveLocation(LatLng data) async {
    Timer(const Duration(seconds: 1), () async {
      lat = data.latitude;
      lng = data.longitude;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("lat", data.latitude.toStringAsFixed(8));
      prefs.setString("lng", data.longitude.toStringAsFixed(8));
      GeoData data1 = await Geocoder2.getDataFromCoordinates(
          latitude: lat, longitude: lng, googleMapApiKey: apiKey);
      setState(() {
        currentAddress = data1.address;
        button = true;
      });
      await updateLocationInDatabase(lat, lng);
    });
  }

  void getPlaces(context) async {
    setState(() {
      button = false;
    });

    final Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: apiKey,
      onError: onError,
      mode: Mode.overlay,
      language: 'en',
      components: [Component(Component.country, 'in')],
    );

    if (p != null) displayPrediction(p);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'Unknown error'),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: apiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(p.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    _getCameraMoveLocation(LatLng(lat, lng));
    // print("${p.description} - $lat/$lng");

    final marker = Marker(
      markerId: const MarkerId('location'),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      markers[const MarkerId('location')] = marker;
      _goToTheLake(lat, lng);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: const Center(
            child: const Text(
              'Update New Location',
              style: TextStyle(fontSize: 16.7, color: Colors.white),
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.my_location, color: Colors.white),
                  iconSize: 30,
                  onPressed: isLoading ? null : _getLocation,
                ))
          ],
          bottom: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width * 0.85, 52),
              child: GestureDetector(
                onTap: () {
                  getPlaces(context);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 52,
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                      color: CustomTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 25,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Enter Location',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: kGooglePlex!,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  buildingsEnabled: true,
                  markers: markers.values.toSet(),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _goToTheLake(lat, lng);
                    final marker = Marker(
                      markerId: const MarkerId('location'),
                      position: LatLng(lat, lng),
                      icon: BitmapDescriptor.defaultMarker,
                    );
                    setState(() {
                      markers[const MarkerId('location')] = marker;
                    });
                  },
                  onCameraIdle: () {
                    getMapLoc();
                  },
                  onCameraMove: (post) {
                    lat = post.target.latitude;
                    lng = post.target.longitude;

                    final marker = Marker(
                      markerId: const MarkerId('location'),
                      position: LatLng(lat, lng),
                      icon: BitmapDescriptor.defaultMarker,
                    );
                    setState(() {
                      markers[const MarkerId('location')] = marker;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            color: CustomTheme.backgroundColor,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/images/map_pin.png',
                  scale: 3,
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: Text(
                    '${currentAddress}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          (button)
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: CustomTheme.loginGradientStart,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w400)),
                  onPressed: isLoading ? null : handleContinuePressed,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Continue',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w400),
                        ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400)),
                  onPressed: isLoading ? null : handleContinuePressed,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Continue',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                )
        ],
      ),
    );
  }

  void getMapLoc() async {
    _getCameraMoveLocation(LatLng(lat, lng));
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    final int special = 8 + _random.nextInt(4);
    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
