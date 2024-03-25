import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:pos/app/routes/app_routes.dart';
import 'package:pos/table/views/table_grid_view.dart';
import '../../authentication/views/pin_screen.dart';
import '../../shared/home.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.HOME,
      page: () => Home(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const PinScreen(),
    ),
    GetPage(
      name: Routes.TableManagement,
      page: () => const TableGridView(),
    ),
  ];
}
