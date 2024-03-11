import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:pos/app/routes/app_routes.dart';
import '../../authentication/views/pin_screen.dart';
import '../../shared/home.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.HOME,
      page: () => const Home(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () {
        return const PinScreen(
        );
      },
    ),
  ];
}
