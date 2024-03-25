import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../authentication/controllers/auth_controller.dart';
import '../table/views/table_grid_view.dart';
import '../table/widgets/Iconbuttom.dart';
import '../table/widgets/appbar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

AuthController authController = Get.put(AuthController());

class _HomeState extends State<Home> {
  String currentTime = '';
  Timer? timer;
  int selectedPage = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateTime();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());
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

  void performSearch(String query) {
    print('Searching for: $query');
  }

  void navigateToPage(int pageIndex) {
    setState(() {
      selectedPage = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(currentTime: currentTime),
      body: Row(
        key: const ValueKey('home'),
        children: [
          //Side bar
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  CustomIconButton(
                    onTap: () {
                      navigateToPage(0);
                    },
                    icon: Icons.dashboard_outlined,
                    text: "Dashboard",
                    selectedIcon: selectedPage,
                    index: 0, // Index du bouton
                  ),
                  SizedBox(height:10),
                  CustomIconButton(
                    onTap: () {
                      navigateToPage(1);
                    },
                    icon: Icons.table_bar,
                    text: "Table management",
                    selectedIcon: selectedPage,
                    index: 1, // Index du bouton
                  ),
                  SizedBox(height:10),
                  CustomIconButton(
                    onTap: () {
                      navigateToPage(2);
                    },
                    icon: Icons.restaurant_menu_outlined,
                    text: "Dishes management ",
                    selectedIcon: selectedPage,
                    index: 2, // Index du bouton
                  ),
                  SizedBox(height:10),
                  CustomIconButton(
                    onTap: () {
                      navigateToPage(3); // Naviguer vers la page correspondante
                    },
                    icon: Icons.reorder_outlined,
                    text: "Order Line",
                    selectedIcon: selectedPage,
                    index: 3, // Index du bouton
                  ),
                  Spacer(),
                  CustomIconButton(
                    onTap: () {
                      navigateToPage(5);
                    },
                    icon: Icons.logout_outlined,
                    text: "Logout",
                    selectedIcon: selectedPage,
                    index: 5, // Index du bouton
                  ),
                ],
              ),
            ),
          ),
          // views
          Expanded(
            flex: 7,
            child: IndexedStack(
              index: selectedPage,
              children: [
                DashboardPage(),
                TableGridView(),
                RoomManagementPage(),
                DashboardPage(),
                DashboardPage(),
                LoginPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Text('Dashboard Page'),
      ),
    );
  }
}

class TableManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table Management'),
      ),
      body: Center(
        child: Text('Table Management Page'),
      ),
    );
  }
}

class RoomManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Management'),
      ),
      body: Center(
        child: Text('Room Management Page'),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Text('Login Page'),
      ),
    );
  }
}
