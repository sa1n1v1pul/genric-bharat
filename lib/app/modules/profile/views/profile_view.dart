import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/core/theme/theme.dart';
import 'package:handyman/app/modules/profile/controller/profile_controller.dart';
import 'package:handyman/app/modules/profile/views/edit_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../auth/controllers/auth_controller.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? _imagePath;
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _loadImagePath();
  }

  Future<void> _loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
      await _saveImagePath(pickedFile.path);
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
              if (_imagePath != null)
                ListTile(
                  leading: Icon(Icons.delete,
                      color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart),
                  title: Text('Remove photo',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
                      )),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart),
                title: Text('Take a picture',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
                    )),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library,
                    color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart),
                title: Text('Choose from gallery',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
                    )),
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
    setState(() {
      _imagePath = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_profileController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imagePath != null
                            ? FileImage(File(_imagePath!))
                            : null,
                        child: _imagePath == null
                            ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                            : null,
                      ),
                    ),
                    Text(
                      _profileController.userData.value['fullname'] ?? 'Verified Customer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      _profileController.userData.value['mobile_number'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : const Color.fromARGB(255, 92, 91, 91),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => const EditProfile());
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
                        backgroundColor: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white,
                        side: BorderSide(
                            color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildProfileItem(Icons.help_outline, 'Help Center', isDarkMode),
                        _buildProfileItem(Icons.language, 'About BDS Infotech', isDarkMode),
                        _buildProfileItem(Icons.star_border, 'My Rating', isDarkMode),
                        _buildProfileItem(Icons.calendar_today, 'Scheduled Booking', isDarkMode),
                        _buildProfileItem(Icons.thumb_up_outlined, 'Rate Us', isDarkMode),
                        _buildProfileItem(Icons.credit_card, 'Add Payment Method', isDarkMode),
                        _buildProfileItem(Icons.privacy_tip_outlined, 'Privacy policy', isDarkMode),
                        _buildProfileItem(Icons.description_outlined, 'Terms and conditions', isDarkMode),
                        _buildProfileItem(Icons.logout, 'Logout', isDarkMode, Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, bool isDarkMode, [Color? iconColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        child: ListTile(
          leading: Container(
            width: 24,
            alignment: Alignment.centerLeft,
            child: Icon(icon,
                color: iconColor ?? (isDarkMode ? Colors.white : CustomTheme.loginGradientStart)),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: iconColor == Colors.red
                  ? Colors.red
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onTap: () {
            if (title == 'Logout') {
              _handleLogout();
            }
          },
        ),
      ),
    );
  }

  void _handleLogout() {
    final AuthController authController = Get.find<AuthController>();
    authController.logout();
  }
}