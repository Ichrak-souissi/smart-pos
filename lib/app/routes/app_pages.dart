// app/routes/app_pages.dart



import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:pos/app/routes/app_routes.dart';
import '../../authentication/views/pin_screen.dart';
import '../../main.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const PinScreen(),
    ),
  ];
}
