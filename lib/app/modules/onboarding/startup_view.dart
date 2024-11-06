import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/controllers/auth_controller.dart';
import '../auth/views/loginview.dart';
import '../widgets/mainlayout.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  final AuthController _authController = Get.put(AuthController());
  final List<String> backgroundImages = [
    "assets/images/genric4.jpg",
    'assets/images/genric3.jpg',
    'assets/images/genric2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _preloadImages();
    });
    goWelcomePage();
  }

  Future<void> _preloadImages() async {
    await Future.wait([
      ...backgroundImages
          .map((image) => precacheImage(AssetImage(image), context)),
    ]);
  }

  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 6));
    navigateToNextScreen();
  }

  void navigateToNextScreen() {
    if (_authController.isLoggedIn.value) {
      Get.off(() => const MainLayout());
    } else {
      Get.off(() => LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackgroundImage(images: backgroundImages),
    );
  }
}

class AnimatedBackgroundImage extends StatefulWidget {
  final List<String> images;

  const AnimatedBackgroundImage({super.key, required this.images});

  @override
  _AnimatedBackgroundImageState createState() =>
      _AnimatedBackgroundImageState();
}

class _AnimatedBackgroundImageState extends State<AnimatedBackgroundImage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startImageAnimation();
  }

  void _startImageAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
        });
        _startImageAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: Image.asset(
        widget.images[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
