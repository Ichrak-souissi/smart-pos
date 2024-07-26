import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:pos/admin/item_management.dart';
import 'package:pos/admin/staff_management.dart';
import 'package:pos/app/routes/app_routes.dart';
import 'package:pos/waiter/room_view.dart';
import 'package:pos/shared/dashboard.dart';
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
      page: () => const PinScreen(),
    ),
    GetPage(
      name: Routes.RoomManagement,
      page: () => RoomView(),
    ),
    GetPage(
      name: Routes.Dashboard,
      page: () => DashboardPage(),
    ),
    GetPage(
      name: Routes.StaffManagement,
      page: () => StaffManagement(),
    ),
    GetPage(
      name: Routes.ItemManagement,
      page: () => ItemManagement(),
    )
  ];
}
