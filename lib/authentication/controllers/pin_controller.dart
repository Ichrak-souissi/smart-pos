import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:pos/authentication/controllers/auth_controller.dart';
import 'package:pos/constants.dart';

import '../../Dio/client_dio.dart';
import '../../shared/home.dart';
import '../models/user.dart';

class PinController extends GetxController {
  final ClientDio _clientDio = ClientDio();
  late User? user;

  Future<void> sendPin(String pin) async {
    try {
      final response = await _clientDio.dio.post(
        Constants.getLoginUrl(),
        data: {'code': pin},
      );

      if (response.statusCode == 200) {
        Logger().i(response.data);
        user = User.fromJson(response.data);
        Logger().d(user!.code);
        AuthController().isLoggedIn(true);
        GetStorage().write('isLoggedIn', true);
        Get.offAll( const Home());
      } else {
        throw (
          response: response,
          requestOptions: response.requestOptions,
        );
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        Get.snackbar('Le code tapé est incorrect', 'Vérifiez votre code pin ');
      }
    }catch (e) {
      Get.snackbar('Erreur', '$e');
    }
  }
}
