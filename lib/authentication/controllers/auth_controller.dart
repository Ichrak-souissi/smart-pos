import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  late final isLoggedIn = false.obs;
  final pinCode = ''.obs;
  final userName = ''.obs;
  final userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = GetStorage().read('isLoggedIn') ?? false;
    pinCode.value = GetStorage().read('pinCode') ?? '';
    userName.value = GetStorage().read('userName') ?? '';
    userRole.value = GetStorage().read('userRole') ?? '';
  }

  void setLoggedIn(bool value) {
    isLoggedIn.value = value;
    GetStorage().write('isLoggedIn', value);
  }

  void savePinCode(String pin) {
    pinCode.value = pin;
    GetStorage().write('pinCode', pin);
  }

  String getUserName() => userName.value;
}
