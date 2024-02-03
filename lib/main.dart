import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos/shared/home.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'authentication/views/pin_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {


    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: Routes.LOGIN,
      getPages: AppPages.pages,
      home: authController.isLoggedIn ? const Home() : const PinScreen(),

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
