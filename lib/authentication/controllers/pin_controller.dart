import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:pos/authentication/controllers/secure_storage.dart';

import '../../main.dart';
import '../../shared/home.dart';
import '../models/user.dart';

import 'package:dio/dio.dart';

class PinController extends GetxController {
  final Dio _dio = Dio();
  final String _pinUrl = 'http://127.0.0.1:3000/users/login';
  late final User user  ;

  void onLoginSuccess() {
    AuthController().isLoggedIn = true;
    GetStorage().write('isLoggedIn', true);
    Get.off(const Home());
  }
  Future<void> sendPin(String pin) async {
    try {
      final response = await _dio.post(
        _pinUrl,
        data: {'code': pin},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Handle the response
      if (response.statusCode == 200) {
        // PIN sent successfully
        Logger().i(response.data) ;
        user= User.fromJson(response.data)  ;
        Logger().d(user.code) ;
        AuthController().isLoggedIn = true;
        GetStorage().write('isLoggedIn', true);
        onLoginSuccess() ;
        print('PIN sent successfully');
      } else {
        // Handle other status codes
        print('Failed to send PIN: ${response.statusCode}');
      }
    } on DioError catch (e) {
      // Handle Dio errors
      print('Dio error: ${e.message}');
    } catch (e) {
      // Handle other exceptions
      print('Exception: $e');
    }
  }
}