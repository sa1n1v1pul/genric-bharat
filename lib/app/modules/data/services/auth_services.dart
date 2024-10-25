import 'package:get/get.dart';

class AuthService extends GetxService {
  Future<bool> signIn(String email, String password) async {
    // Implement your sign in logic here
    // This is just a mock implementation
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  Future<bool> signUp(String name, String email, String password) async {
    // Implement your sign up logic here
    // This is just a mock implementation
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    // Implement your forgot password logic here
    // This is just a mock implementation
    await Future.delayed(Duration(seconds: 2));
    return true;
  }
}
