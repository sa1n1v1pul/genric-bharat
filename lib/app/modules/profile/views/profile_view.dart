import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dynamicpages.dart';
import '../../widgets/myprescriptionview.dart';
import '../controller/profile_controller.dart';
import 'edit_profile.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key) {
    // Ensure controller is registered
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    // Wait for next frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // First load userId, then get user data
      await controller.loadUserIdFromPrefs();
    });
  }

  final AuthController _authController = Get.find<AuthController>();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        await controller.updateProfileImage(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    showModalBottomSheet(
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (controller.profileImagePath.isNotEmpty)
                ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: isDarkMode ? Colors.white : Colors.red,
                    size: 24 * textScaleFactor,
                  ),
                  title: Text(
                    'Remove photo',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.red,
                      fontSize: 16 * textScaleFactor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.removeProfileImage();
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 24 * textScaleFactor,
                ),
                title: Text(
                  'Take a picture',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16 * textScaleFactor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 24 * textScaleFactor,
                ),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16 * textScaleFactor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider? _getProfileImage() {
    try {
      final networkUrl = controller.userData.value['profile'];
      final localPath = controller.profileImagePath.value;

      if (localPath.isNotEmpty) {
        if (localPath.startsWith('http')) {
          return NetworkImage(localPath, headers: const {
            'Cache-Control': 'max-age=3600',
          });
        } else if (File(localPath).existsSync()) {
          return FileImage(File(localPath));
        }
      }

      if (networkUrl != null && networkUrl.isNotEmpty) {
        return NetworkImage(networkUrl, headers: const {
          'Cache-Control': 'max-age=3600',
        });
      }

      return null;
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
  }

  void _navigateToDynamicPage(String title, String slug) {
    Get.to(() => DynamicPageScreen(
          title: title,
          slug: slug,
        ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive sizes
    final avatarRadius = (50 * textScaleFactor).clamp(40.0, 70.0);
    final iconSize = (24 * textScaleFactor).clamp(20.0, 32.0);
    final smallIconSize = (20 * textScaleFactor).clamp(16.0, 28.0);
    final paddingSize = (16 * textScaleFactor).clamp(12.0, 24.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          print('ProfileView rebuild - userId: ${controller.userId.value}');
          print(
              'ProfileView rebuild - isLoading: ${controller.isLoading.value}');
          print(
              'ProfileView rebuild - userData empty: ${controller.userData.value.isEmpty}');

          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error/retry state if no data and not loading
          if (controller.userData.value.isEmpty &&
              !controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Unable to load profile data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.getUserData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userData = controller.userData.value;
          final fullName = userData['fullname'] ?? userData['name'] ?? '';
          final mobileNumber = userData['mobile_number'] ?? '';
          final email = userData['email'] ?? '';

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(paddingSize),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => _showImageSourceActionSheet(context),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: Colors.grey[300],
                                child: Obx(() {
                                  if (controller.isImageLoading.value) {
                                    return const CircularProgressIndicator();
                                  }

                                  final profileImage = _getProfileImage();
                                  if (profileImage == null) {
                                    return Icon(
                                      Icons.person,
                                      size: avatarRadius,
                                      color: Colors.grey[600],
                                    );
                                  }

                                  return Container(
                                    width: avatarRadius * 2,
                                    height: avatarRadius * 2,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: profileImage,
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          print(
                                              'Error loading image: $exception');
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4 * textScaleFactor),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.loginGradientStart,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: smallIconSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: TextStyle(
                                fontSize:
                                    (17 * textScaleFactor).clamp(14.0, 24.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (mobileNumber.isNotEmpty)
                              Text(
                                mobileNumber,
                                style: TextStyle(
                                  fontSize:
                                      (15 * textScaleFactor).clamp(12.0, 20.0),
                                  color: Colors.grey[600],
                                ),
                              ),
                            Container(
                              width: screenWidth * 0.5,
                              child: Text(
                                email,
                                style: TextStyle(
                                  fontSize:
                                      (16 * textScaleFactor).clamp(14.0, 22.0),
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: paddingSize),
                    TextButton(
                      onPressed: () async {
                        await Get.to(() => const EditProfile());
                        controller.getUserData();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * textScaleFactor,
                          vertical: 8 * textScaleFactor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20 * textScaleFactor),
                          side: BorderSide(
                            color: CustomTheme.loginGradientStart,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: CustomTheme.loginGradientStart,
                              fontSize:
                                  (14 * textScaleFactor).clamp(14.0, 20.0),
                            ),
                          ),
                          SizedBox(width: 8 * textScaleFactor),
                          Icon(
                            Icons.arrow_forward,
                            color: CustomTheme.loginGradientStart,
                            size: smallIconSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(paddingSize),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[900]
                        : CustomTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30 * textScaleFactor),
                      topRight: Radius.circular(30 * textScaleFactor),
                    ),
                  ),
                  child: ListView(
                    children: [
                      _buildProfileItem(
                        Icons.location_on_outlined,
                        'Manage Addresses',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () => Get.toNamed(Routes.DELIVERY),
                      ),
                      _buildProfileItem(
                        Icons.list_alt,
                        'My Orders',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () => Get.toNamed(Routes.MY_ORDERS),
                      ),
                      _buildProfileItem(
                        Icons.medical_services_outlined,
                        'My Prescriptions',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () => Get.toNamed(PrescriptionListScreen.route),
                      ),
                      _buildProfileItem(
                        Icons.book_outlined,
                        'Blogs',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () => controller.navigateToVlogsList(),
                      ),
                      _buildProfileItem(
                        Icons.thumb_up_outlined,
                        'Rate Us',
                        isDarkMode,
                        textScaleFactor,
                      ),
                      _buildProfileItem(
                        Icons.star_border,
                        'My Rating',
                        isDarkMode,
                        textScaleFactor,
                      ),
                      _buildProfileItem(
                        Icons.privacy_tip_outlined,
                        'Privacy Policy',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () => _navigateToDynamicPage(
                            'Privacy Policy', 'privacy-policy'),
                      ),
                      _buildProfileItem(
                        Icons.help_outline,
                        'Return Policy',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () => _navigateToDynamicPage(
                            'Return Policy', 'return-policy'),
                      ),
                      _buildProfileItem(
                        Icons.language,
                        'About Us',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () =>
                            _navigateToDynamicPage('About Us', 'about-us'),
                      ),
                      _buildProfileItem(
                        Icons.description_outlined,
                        'Terms and Conditions',
                        isDarkMode,
                        textScaleFactor,
                        onTap: () => _navigateToDynamicPage(
                            'Terms and Conditions', 'terms-and-service'),
                      ),
                      _buildProfileItem(
                        Icons.logout,
                        'Logout',
                        isDarkMode,
                        textScaleFactor,
                        color: Colors.red,
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProfileItem(
      IconData icon, String title, bool isDarkMode, double textScaleFactor,
      {Color? color, VoidCallback? onTap}) {
    final iconSize = (22 * textScaleFactor).clamp(20.0, 24.0);

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isDarkMode ? Colors.white : Colors.black),
          size: iconSize,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? (isDarkMode ? Colors.white : Colors.black),
            fontSize: (15 * textScaleFactor).clamp(16.0, 22.0),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          size: iconSize,
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleLogout() {
    final textScaleFactor =
        Get.context != null ? MediaQuery.of(Get.context!).textScaleFactor : 1.0;

    Get.defaultDialog(
      title: 'Logout',
      titleStyle: TextStyle(
        fontSize: (15 * textScaleFactor).clamp(16.0, 22.0),
      ),
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        // Clear ProfileController data
        await controller.clearUserData();
        // Perform logout in AuthController
        await _authController.logout();
        Get.back();
      },
      confirm: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red, // Set red background color for Yes button
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () async {
            // Clear ProfileController data
            await controller.clearUserData();
            // Perform logout in AuthController
            await _authController.logout();
            Get.back();
          },
          child: const Text(
            'Yes',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      cancel: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomTheme.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            Get.back();
          },
          child: const Text('No', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
