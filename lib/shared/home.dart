import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pos/admin/staff_management.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/authentication/views/pin_screen.dart';
import 'package:pos/item/views/item_status_managment.dart';
import 'package:pos/shared/dashboard.dart';
import 'package:pos/shared/icon_buttom.dart';
import 'package:pos/waiter/order_view.dart';
import 'package:pos/waiter/order_view_waiter.dart';
import 'package:pos/waiter/room_view.dart';
import 'package:pos/admin/room_view_admin.dart';
import 'package:pos/app/routes/app_routes.dart';
import 'package:pos/admin/item_management.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentTime = '';
  Timer? timer;
  int selectedPage = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    updateTime();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());

    final userRole = storage.read('userRole') ?? '';
    setState(() {
      selectedPage = (userRole == 'admin')
          ? 0
          : (userRole == 'waiter')
              ? 1
              : 2;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(now);
    setState(() {
      currentTime = formattedTime;
    });
  }

  void navigateToPage(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });

    switch (pageIndex) {
      case 0:
        _navigatorKey.currentState
            ?.pushReplacement(_pageRouteBuilder(DashboardPage()));
        break;
      case 1:
        _navigatorKey.currentState
            ?.pushReplacement(_pageRouteBuilder(_roomView()));
        break;
      case 2:
        _navigatorKey.currentState
            ?.pushReplacement(_pageRouteBuilder(_itemManagementOrOrderView()));
        break;
      case 3:
        _navigatorKey.currentState
            ?.pushReplacement(_pageRouteBuilder(_staffManagementOrDashboard()));
        break;
      default:
        _navigatorKey.currentState
            ?.pushReplacement(_pageRouteBuilder(DashboardPage()));
        break;
    }
  }

  PageRouteBuilder _pageRouteBuilder(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  Widget _roomView() {
    final userRole = storage.read('userRole') ?? '';
    if (userRole == 'admin') {
      return const RoomViewAdmin();
    } else if (userRole == 'chief') {
      return const OrdersView();
    } else {
      return const RoomView();
    }
  }

  Widget _itemManagementOrOrderView() {
    final userRole = storage.read('userRole') ?? '';
    if (userRole == 'admin') {
      return ItemManagement();
    } else if (userRole == 'chief') {
      return ItemStatusManagement();
    } else {
      return OrdersViewWaiter();
    }
  }

  Widget _staffManagementOrDashboard() {
    final userRole = storage.read('userRole') ?? '';
    return (userRole == 'admin') ? const StaffManagement() : DashboardPage();
  }

  void logout() {
    Get.offAll(() => const PinScreen());
  }

  @override
  Widget build(BuildContext context) {
    final userRole = storage.read('userRole') ?? '';

    if (userRole.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Unauthorized access"),
        ),
      );
    }

    List<Widget> getSidebarButtons() {
      List<Widget> buttons = [];

      if (userRole == 'admin') {
        buttons.addAll([
          CustomIconButton(
              onTap: () => navigateToPage(0),
              icon: Icons.dashboard_outlined,
              selectedIcon: selectedPage,
              index: 0),
          const SizedBox(height: 15),
          CustomIconButton(
              onTap: () => navigateToPage(1),
              icon: Icons.table_bar,
              selectedIcon: selectedPage,
              index: 1),
          const SizedBox(height: 15),
          CustomIconButton(
              onTap: () => navigateToPage(2),
              icon: Icons.list_alt,
              selectedIcon: selectedPage,
              index: 2),
          const SizedBox(height: 15),
          CustomIconButton(
              onTap: () => navigateToPage(3),
              icon: Icons.supervisor_account_outlined,
              selectedIcon: selectedPage,
              index: 3),
          const SizedBox(height: 15),
        ]);
      } else if (userRole == 'waiter') {
        buttons.addAll([
          CustomIconButton(
              onTap: () => navigateToPage(1),
              icon: Icons.table_bar,
              selectedIcon: selectedPage,
              index: 1),
          const SizedBox(height: 15),
          CustomIconButton(
              onTap: () => navigateToPage(2),
              icon: Icons.list_alt,
              selectedIcon: selectedPage,
              index: 2),
          const SizedBox(height: 15),
        ]);
      } else if (userRole == 'chief') {
        buttons.addAll([
          CustomIconButton(
              onTap: () => navigateToPage(1),
              icon: Icons.table_bar,
              selectedIcon: selectedPage,
              index: 1),
          const SizedBox(height: 15),
          CustomIconButton(
              onTap: () => navigateToPage(2),
              icon: Icons.list_alt,
              selectedIcon: selectedPage,
              index: 2),
          const SizedBox(height: 15),
        ]);
      }

      buttons.add(const Spacer());
      buttons.add(CustomIconButton(
          onTap: logout,
          icon: Icons.logout_outlined,
          selectedIcon: selectedPage,
          index: 4));
      buttons.add(const SizedBox(height: 10));

      return buttons;
    }

    String initialRoute = userRole == 'admin'
        ? Routes.Dashboard
        : (userRole == 'waiter')
            ? Routes.RoomManagement
            : Routes.OrdersManagement;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 255, 245),
      body: Row(
        key: const ValueKey('home'),
        children: [
          const SizedBox(height: 10),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 5, left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getSidebarButtons(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Navigator(
              key: _navigatorKey,
              initialRoute: initialRoute,
              onGenerateRoute: (RouteSettings settings) {
                WidgetBuilder builder;
                switch (settings.name) {
                  case Routes.Dashboard:
                    builder = (BuildContext _) => DashboardPage();
                    break;
                  case Routes.RoomManagement:
                    builder = (BuildContext _) => _roomView();
                    break;
                  case Routes.ItemManagement:
                    builder = (BuildContext _) => ItemManagement();
                    break;
                  case Routes.StaffManagement:
                    builder = (BuildContext _) => _staffManagementOrDashboard();
                    break;
                  case Routes.OrdersManagement:
                    builder = (BuildContext _) => _itemManagementOrOrderView();
                    break;
                  default:
                    builder = (BuildContext _) => DashboardPage();
                }

                return PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      builder(context),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
