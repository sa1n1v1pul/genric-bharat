import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CustomTheme {
  static final Rx<Color> _loginGradientStart = Colors.blue.shade300.obs;
  static final Rx<Color> _backgroundColor = const Color(0xffeff8ff).obs;
  static const Color loginGradientEnd = Color.fromARGB(255, 229, 224, 226);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static Color get backgroundColor => _backgroundColor.value;

  static final List<Color> themeColors = [
    const Color.fromARGB(255, 236, 72, 127),
    Colors.orange,
    Colors.red,
    Colors.amber,
    Colors.teal,
    Colors.green,
    const Color.fromARGB(255, 117, 91, 248),
    Colors.blue.shade300,
    Colors.purple,
    const Color.fromARGB(255, 105, 90, 3),
    Colors.brown,
    Colors.black,
  ];

  static Color get loginGradientStart => _loginGradientStart.value;

  // Helper method to create background color with opacity
  static Color _createBackgroundColor(Color baseColor) {
    return Color.fromRGBO(
      baseColor.red,
      baseColor.green,
      baseColor.blue,
      0.1, // 10% opacity
    );
  }

  static LinearGradient get primaryGradient => LinearGradient(
    colors: <Color>[loginGradientStart, loginGradientEnd],
    stops: const <double>[0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get appBarGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [loginGradientStart, Colors.white],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: loginGradientStart,
      scaffoldBackgroundColor: white,
      appBarTheme: AppBarTheme(
        color: loginGradientStart,
        iconTheme: const IconThemeData(color: white),
      ),
      colorScheme: ColorScheme.light(
        surface: backgroundColor,
        primary: loginGradientStart,
        secondary: loginGradientEnd,
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: loginGradientEnd,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: loginGradientStart,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static void changeTheme(int colorIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update login gradient color
      _loginGradientStart.value = themeColors[colorIndex];

      // Update background color based on the new theme color with 0.1 opacity
      _backgroundColor.value = _createBackgroundColor(themeColors[colorIndex]);

      Get.changeTheme(lightTheme);
      GetStorage().write('themeColorIndex', colorIndex);
      Get.forceAppUpdate();
    });
  }

  static void loadSavedTheme() {
    final savedColorIndex = GetStorage().read('themeColorIndex');
    final isDarkMode = GetStorage().read('isDarkMode') ?? false;
    _themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(_themeMode.value);

    if (savedColorIndex != null) {
      // This will update both loginGradientStart and backgroundColor
      changeTheme(savedColorIndex);
    } else {
      // Set default color to Color.fromARGB(255, 117, 91, 248)
      changeTheme(7);
    }
  }

  static final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;
  static ThemeMode get themeMode => _themeMode.value;

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: loginGradientStart,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        color: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      colorScheme: ColorScheme.dark(
        surface: backgroundColor,
        primary: loginGradientStart,
        secondary: loginGradientEnd,
      ),
      cardTheme: CardTheme(
        color: Colors.grey[800],
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[900],
        selectedItemColor: loginGradientStart,
        unselectedItemColor: Colors.grey[400],
      ),
    );
  }

  static void toggleTheme() {
    _themeMode.value =
    _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    // Update background color based on the current login gradient color
    if (_themeMode.value == ThemeMode.dark) {
      _backgroundColor.value = Colors.blueGrey;
    } else {
      _backgroundColor.value = _createBackgroundColor(_loginGradientStart.value);
    }

    GetStorage().write('isDarkMode', _themeMode.value == ThemeMode.dark);
    Get.changeThemeMode(_themeMode.value);
  }
}

class TColor {
  static Color get primary => const Color(0xffFC6011);
  static Color get primaryText => const Color(0xff4A4B4D);
  static Color get secondaryText => const Color(0xff7C7D7E);
  static Color get textfield => const Color(0xffF2F2F2);
  static Color get placeholder => const Color(0xffB6B7B7);
  static Color get white => const Color(0xffffffff);
}