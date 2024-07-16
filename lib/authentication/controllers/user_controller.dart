import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pos/constants.dart';
import '../models/user.dart';

class UserController extends GetxController {
  final Dio _dio = Dio();
  final users = RxList<User>();

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    try {
      final response = await _dio.get(Constants.getUsersUrl());

      if (response.statusCode == 200) {
        final jsonData = response.data;
        final List<User> usersList = (jsonData as List)
            .map((jsonUser) => User.fromJson(jsonUser))
            .toList();
        users.assignAll(usersList);
      } else {
        print('Failed to load users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<User?> addUser(User newUser) async {
    try {
      final response = await _dio.post(
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

  Future<User?> updateUser(User user) async {
    try {
      final url = Constants.updateUserUrl(user.id);

      final response = await _dio.patch(
        url,
        data: {
          'id': user.id,
          'name': user.name,
          'role': user.role,
          'code': user.code,
          'phone': user.phone,
        },
      );

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(response.data);
        final index = users.indexWhere((u) => u.id == updatedUser.id);
        if (index != -1) {
          users[index] = updatedUser;
        }
        return updatedUser;
      } else {
        print('Failed to update user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final url = Constants.deleteUserUrl(userId);
      final response = await _dio.delete(url);

      if (response.statusCode == 200) {
        users.removeWhere((user) => user.id == userId);
      } else {
        print('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
