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
  ProfileView({Key? key}) : super(key: key);

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
                  ),
                  title: Text(
                    'Remove photo',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Add remove photo logic if needed
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Take a picture',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
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
                ),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
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
          return NetworkImage(localPath);
        } else if (File(localPath).existsSync()) {
          return FileImage(File(localPath));
        }
      }

      if (networkUrl != null && networkUrl.isNotEmpty) {
        return NetworkImage(networkUrl);
      }

      return null;
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
  }

  // New method to handle dynamic page navigation
  void _navigateToDynamicPage(String title, String slug) {
    Get.to(() => DynamicPageScreen(
      title: title,
      slug: slug,
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // Debug prints
          print('Building ProfileView');
          print('IsLoading: ${controller.isLoading.value}');
          print('UserData: ${controller.userData.value}');

          final userData = controller.userData.value;

          // Show loading only during initial load
          if (controller.isLoading.value && userData.isEmpty) {
            print('Showing loading indicator');
            return const Center(child: CircularProgressIndicator());
          }

          final fullName = userData['fullname'] ?? 'User';
          final mobileNumber = userData['mobile_number'] ?? '';
          final email = userData['email'] ?? 'User@gmail.com';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                child: Obx(() {
                                  if (controller.isImageLoading.value) {
                                    return const CircularProgressIndicator();
                                  }

                                  final profileImage = _getProfileImage();
                                  if (profileImage == null) {
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[600],
                                    );
                                  }

                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: profileImage,
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          print('Error loading image: $exception');
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
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.loginGradientStart,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
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
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (mobileNumber.isNotEmpty)
                              Text(
                                mobileNumber,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        await Get.to(() => const EditProfile());
                        controller.getUserData();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: CustomTheme.loginGradientStart,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : CustomTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    children: [
                      _buildProfileItem(
                        Icons.location_on_outlined,
                        'Manage Addresses',
                        isDarkMode,
                        onTap: () => Get.toNamed(Routes.DELIVERY),
                      ),
                      _buildProfileItem(
                        Icons.list_alt,
                        'My Orders',
                        isDarkMode,
                        onTap: () => Get.toNamed(Routes.MY_ORDERS),
                      ),
                      _buildProfileItem(
                        Icons.medical_services_outlined,
                        'My Prescriptions',
                        isDarkMode,
                        onTap: () => Get.toNamed(PrescriptionListScreen.route),
                      ),
                      _buildProfileItem(
                        Icons.book_outlined,
                        'Blogs',
                        isDarkMode,
                        onTap: () => controller.navigateToVlogsList(),
                      ),
                      _buildProfileItem(
                        Icons.thumb_up_outlined,
                        'Rate Us',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.star_border,
                        'My Rating',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.privacy_tip_outlined,
                        'Privacy Policy',
                        isDarkMode,
                        onTap: () => _navigateToDynamicPage('Privacy Policy', 'privacy-policy'),
                      ),
                      _buildProfileItem(
                        Icons.help_outline,
                        'Return Policy',
                        isDarkMode,
                        onTap: () => _navigateToDynamicPage('Return Policy', 'return-policy'),
                      ),
                      _buildProfileItem(
                        Icons.language,
                        'About Us',
                        isDarkMode,
                        onTap: () => _navigateToDynamicPage('About Us', 'about-us'),
                      ),
                      _buildProfileItem(
                        Icons.description_outlined,
                        'Terms and Conditions',
                        isDarkMode,
                        onTap: () => _navigateToDynamicPage('Terms and Conditions', 'terms-and-service'),
                      ),
                      _buildProfileItem(
                        Icons.logout,
                        'Logout',
                        isDarkMode,
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
      IconData icon,
      String title,
      bool isDarkMode,
      {Color? color,
        VoidCallback? onTap}
      ) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isDarkMode ? Colors.white : Colors.black),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleLogout() {
    Get.defaultDialog(
      title: 'Logout',
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
    );
  }
}