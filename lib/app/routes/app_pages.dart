import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:pos/admin/item_management.dart';
import 'package:pos/admin/staff_management.dart';
import 'package:pos/app/routes/app_routes.dart';
import 'package:pos/authentication/views/Welcome_screen.dart';
import 'package:pos/item/views/item_status_managment.dart';
import 'package:pos/waiter/order_view.dart';
import 'package:pos/waiter/order_view_waiter.dart';
import 'package:pos/waiter/room_view.dart';
import 'package:pos/shared/dashboard.dart';
import '../../authentication/views/pin_screen.dart';
import '../../shared/home.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.Welcome,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => Home(),
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
    ),
    GetPage(name: Routes.OrdersManagement, page: () => const OrdersView()),
    GetPage(name: Routes.OrdersStatusManagment, page: () => OrdersViewWaiter()),
    GetPage(
        name: Routes.ItemStatusManagement,
        page: () => const ItemStatusManagement())
  ];
}
