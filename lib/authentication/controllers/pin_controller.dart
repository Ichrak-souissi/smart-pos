
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../../main.dart';
import '../../shared/home.dart';
import '../models/user.dart';
import 'auth_controller.dart';

class PinController extends GetxController {
  final Dio _dio = Dio();
  final String _pinUrl = 'http://127.0.0.1:3000/users/login';
  late final User user;

  void onLoginSuccess() {
    AuthController().setLoggedIn(true);
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

      if (response.statusCode == 200) {
        Logger().i(response.data);
        user = User.fromJson(response.data);
        Logger().d(user.code);
        AuthController().setLoggedIn(true);
        GetStorage().write('isLoggedIn', true);
        onLoginSuccess();
        print('PIN envoyé avec succès: $pin');
      } else {
        print('Échec de l\'envoi du PIN: ${response.statusCode}');
      }
    } on DioError catch (e) {
      print('Erreur Dio: ${e.message}');
    } catch (e) {
      print('Exception: $e');
    }
  }
}
