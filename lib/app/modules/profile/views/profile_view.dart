// profile_view.dart
import 'package:flutter/material.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../auth/controllers/auth_controller.dart';
import '../controller/profile_controller.dart';
import 'edit_profile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.put(ProfileController());

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        await _profileController.saveProfileImagePath(pickedFile.path);
        setState(() {});
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
              if (_profileController.profileImagePath.isNotEmpty)
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
                    _removePhoto();
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

  void _removePhoto() async {
    await _profileController.removeProfileImagePath();
    setState(() {});
  }

  ImageProvider? _getProfileImage() {
    final localPath = _profileController.profileImagePath.value;
    final networkUrl = _profileController.userData.value['profile'];

    if (localPath.isNotEmpty) {
      return FileImage(File(localPath));
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      return NetworkImage(networkUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (_profileController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final profileImage = _getProfileImage();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => _showImageSourceActionSheet(context),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: profileImage,
                                  child: profileImage == null
                                      ? Icon(Icons.person,
                                      size: 50, color: Colors.grey[600])
                                      : null,
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
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profileController.userData.value['fullname'] ??
                                    'Verified Customer',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.black : Colors.black,
                                ),
                              ),Text(
                                _profileController.userData.value['mobile_number'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                        ],
                      ),
                    ),
                    const SizedBox(height: 16),


                    TextButton(
                      onPressed: () => Get.to(() => const EditProfile()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: CustomTheme.loginGradientStart,
                            width: 1.5, // Outline thickness
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
                        Icons.help_outline,
                        'Help Center',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.language,
                        'About BDS Infotech',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.star_border,
                        'My Rating',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.calendar_today,
                        'Scheduled Booking',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.thumb_up_outlined,
                        'Rate Us',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.credit_card,
                        'Add Payment Method',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.privacy_tip_outlined,
                        'Privacy policy',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.description_outlined,
                        'Terms and conditions',
                        isDarkMode,
                      ),
                      _buildProfileItem(
                        Icons.logout,
                        'Logout',
                        isDarkMode,
                        color: Colors.red,
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

  Widget _buildProfileItem(IconData icon, String title, bool isDarkMode,
      {Color? color}) {
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
        onTap: () {
          if (title == 'Logout') {
            _handleLogout();
          }
        },
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
      onConfirm: () {
        _authController.logout();
        Get.back();
      },
    );
  }
}