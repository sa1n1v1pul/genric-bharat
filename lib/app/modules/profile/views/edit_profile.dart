import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme.dart';
import '../controller/profile_controller.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final ProfileController _profileController = Get.find<ProfileController>();
  final FocusNode phoneFocusNode = FocusNode();
  final RxBool _isMrChecked = false.obs;
  final RxBool _isMrsChecked = false.obs;
  bool isDarkMode = Get.isDarkMode;
  bool initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_profileController.userData.value.isNotEmpty) {
      _updateFormWithData(_profileController.userData.value);
    } else {
      final prefs = await SharedPreferences.getInstance();
      nameController.text = prefs.getString('user_name') ?? '';
      emailController.text = prefs.getString('user_email') ?? '';
      phoneController.text = prefs.getString('user_mobile') ?? '';
      final userTitle = prefs.getString('user_title')?.toLowerCase() ?? '';
      _updateTitleSelection(userTitle);

      // Trigger a refresh of user data from API
      await _profileController.getUserData().then((value) {
        if (_profileController.userData.value.isNotEmpty) {
          _updateFormWithData(_profileController.userData.value);
        }
      });
    }
    initialDataLoaded = true;
  }

  void _updateFormWithData(Map<String, dynamic> data) {
    nameController.text = data['fullname'] ?? '';
    emailController.text = data['email'] ?? '';
    phoneController.text = data['mobile_number'] ?? '';
    final userTitle = data['title']?.toString().toLowerCase() ?? '';
    if (!initialDataLoaded) {
      _updateTitleSelection(userTitle);
    }
  }

  void _updateTitleSelection(String title) {
    _isMrChecked.value = title == 'mr';
    _isMrsChecked.value = title == 'mrs';
  }

  Future<void> _updateProfile() async {
    String title = '';
    if (_isMrChecked.value) title = 'mr';
    if (_isMrsChecked.value) title = 'mrs';

    final updatedData = {
      'title': title,
      'fullname': nameController.text,
      'email': emailController.text,
      'mobile_number': phoneController.text,
    };

    await _profileController.updateUserProfile(updatedData);
  }

  OutlineInputBorder _buildOutlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode
              ? const Color.fromARGB(255, 244, 243, 248)
              : Colors.black,
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            final ThemeData theme = Theme.of(context);
            final bool isDarkMode = theme.brightness == Brightness.dark;

            return Container(
              padding: const EdgeInsets.only(left: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.white)
                        .withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            );
          },
        ),
        toolbarHeight: 60,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        if (_profileController.userData.value.isNotEmpty &&
            !initialDataLoaded) {
          _updateFormWithData(_profileController.userData.value);
        }

        return _profileController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Full Name",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: nameController,
                        cursorColor: isDarkMode ? Colors.white : Colors.black,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          enabledBorder: _buildOutlineInputBorder(
                              isDarkMode ? Colors.white : Colors.black),
                          focusedBorder:
                              _buildOutlineInputBorder(const Color(0xffE15564)),
                          hintText: "Enter Name",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Mr.',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Checkbox(
                                    value: _isMrChecked.value,
                                    onChanged: (bool? value) {
                                      _isMrChecked.value = value ?? false;
                                      if (_isMrChecked.value) {
                                        _isMrsChecked.value = false;
                                      }
                                    },
                                    checkColor: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    activeColor: isDarkMode
                                        ? Colors.white
                                        : CustomTheme.loginGradientStart,
                                    tristate: false,
                                    shape: const CircleBorder(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Mrs.',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Checkbox(
                                    value: _isMrsChecked.value,
                                    onChanged: (bool? value) {
                                      _isMrsChecked.value = value ?? false;
                                      if (_isMrsChecked.value) {
                                        _isMrChecked.value = false;
                                      }
                                    },
                                    checkColor: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    activeColor: isDarkMode
                                        ? Colors.white
                                        : CustomTheme.loginGradientStart,
                                    tristate: false,
                                    shape: const CircleBorder(),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      const SizedBox(height: 30),
                      Text(
                        "Email Address",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        cursorColor: isDarkMode ? Colors.white : Colors.black,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          enabledBorder: _buildOutlineInputBorder(
                              isDarkMode ? Colors.white : Colors.black),
                          focusedBorder:
                              _buildOutlineInputBorder(const Color(0xffE15564)),
                          hintText: "Enter Email",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Phone Number",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        cursorColor: isDarkMode ? Colors.white : Colors.black,
                        controller: phoneController,
                        focusNode: phoneFocusNode,
                        decoration: InputDecoration(
                          border: _buildOutlineInputBorder(
                              isDarkMode ? Colors.white : Colors.black),
                          focusedBorder:
                              _buildOutlineInputBorder(const Color(0xffE15564)),
                          prefix: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          errorStyle: const TextStyle(height: 0),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]*')),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? Colors.white
                                : CustomTheme.loginGradientStart,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                          ),
                          child: Text(
                            "Update Now",
                            style: TextStyle(
                              color: isDarkMode ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
