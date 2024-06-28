import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/authentication/views/pin_screen.dart';
import 'package:pos/order/views/order_view.dart';
import 'package:pos/room/views/room_view.dart';
import 'package:pos/shared/dashboard.dart';
import 'package:pos/shared/icon_buttom.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentTime = '';
  Timer? timer;
  int selectedPage = 0;
  TextEditingController searchController = TextEditingController();
  GlobalKey appBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    updateTime();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(now);
    setState(() {
      currentTime = formattedTime;
    });
  }

  void performSearch(String query) {}

  void navigateToPage(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });
  }

  void logout() {
    Get.offAll(() => const PinScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      //appBar: CustomAppBar(currentTime: currentTime, key: appBarKey),
      body: Row(
        key: const ValueKey('home'),
        children: [
          //Side bar
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    CustomIconButton(
                      onTap: () {
                        navigateToPage(0);
                      },
                      icon: Icons.dashboard_outlined,
                      selectedIcon: selectedPage,
                      index: 0,
                    ),
                    const SizedBox(height: 10),
                    CustomIconButton(
                      onTap: () {
                        navigateToPage(1);
                      },
                      icon: Icons.table_bar,
                      selectedIcon: selectedPage,
                      index: 1,
                    ),
                    const SizedBox(height: 10),
                    CustomIconButton(
                      onTap: () {
                        navigateToPage(2);
                      },
                      icon: Icons.reorder_outlined,
                      //  text: "Gestion des ordres ",
                      selectedIcon: selectedPage,
                      index: 2, // Index du bouton
                    ),
                    const SizedBox(height: 10),
                    const Spacer(),
                    CustomIconButton(
                      onTap: () {
                        logout();
                      },
                      icon: Icons.logout_outlined,
                      //  text: "Déconnecter",
                      selectedIcon: selectedPage,
                      index: 3, // Index du bouton
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: IndexedStack(
              index: selectedPage,
              children: [
                DashboardPage(),
                RoomView(),
                OrderView(),
                DashboardPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
