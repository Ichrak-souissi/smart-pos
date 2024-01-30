import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'authentication/views/pin_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = AuthController();

    return GetMaterialApp(
      title: 'Flutter Auth Example',

      home: authController.isLoggedIn ? HomeScreen() : const PinAuthScreen(),

    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body:const Center(
        child: Text('Welcome back!'),
      ),
    );
  }
}


class AuthController extends GetxController {
  final _isLoggedIn = false.obs;

  bool get isLoggedIn => _isLoggedIn.value;

  set isLoggedIn(bool value) => _isLoggedIn.value = value;

  @override
  void onInit() {
    super.onInit();
    _isLoggedIn.value = GetStorage().read('isLoggedIn') ?? false;
  }
}
