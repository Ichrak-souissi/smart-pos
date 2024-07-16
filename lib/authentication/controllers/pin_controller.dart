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
  final users = RxList<User>();
  final storage = GetStorage();

  Future<void> sendPin(String pin) async {
    try {
      final response = await _clientDio.dio.post(
        Constants.getLoginUrl(),
        data: {'code': pin},
      );

      if (response.statusCode == 200) {
        Logger().i(response.data);
        user = User.fromJson(response.data);

        storage.write('userName', user!.name);
        storage.write('userRole', user!.role);

        print('Nom utilisateur: ${user!.name}');
        print('Rôle utilisateur: ${user!.role}');

        AuthController().setLoggedIn(true);

        Get.offAll(() => const Home());
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
    } catch (e) {
      Get.snackbar('Erreur', '$e');
    }
  }

  Future<void> getAllUsers() async {
    try {
      final response = await _clientDio.dio.get(Constants.getUsersUrl());

      if (response.statusCode == 200) {
        final jsonData = response.data;
        final usersList =
            jsonData.map<User>((jsonUser) => User.fromJson(jsonUser)).toList();
        users.value = usersList;
      } else {
        print('Failed to load users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<User?> addUser(User newUser) async {
    try {
      final response = await _clientDio.dio.post(
        Constants.addUserUrl(),
        data: {
          'name': newUser.name,
          'role': newUser.role,
          'code': newUser.code,
          'phone': newUser.phone,
        },
      );

      if (response.statusCode == 201) {
        final jsonUser = response.data;
        final addedUser = User.fromJson(jsonUser);

        users.add(addedUser);

        //  AuthController().addUser(addedUser);

        return addedUser;
      } else {
        print('Failed to add user');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
