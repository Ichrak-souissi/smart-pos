import 'package:get/get.dart';

import '../models/user.dart';

class UserController extends GetxController {


    Rx<User> user = User(id: 0, name: '', role: 0, code: 0, phone: 0).obs;

  void updateUser(User newUser) {
  user.value = newUser;
  }

  // Add other methods as needed, such as methods for fetching user data from an API

void login ( int pin) {

}

}