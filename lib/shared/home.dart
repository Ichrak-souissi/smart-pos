import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos/authentication/controllers/auth_controller.dart';

import '../table/views/table_grid_view.dart';
import '../table/widgets/left_drawer.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put<AuthController>(AuthController());

    return Scaffold(
      body: Row(
        key: const ValueKey('home'),
        children: [
          Expanded(
            flex: 1,
            child: Drawer(
              elevation: 5,
              backgroundColor: Colors.white,
              shadowColor: Colors.white10,
              surfaceTintColor: Colors.white,
              child: ListView(
                padding: const EdgeInsets.only(left: 10, top: 30 , right: 10),
                shrinkWrap: true,
                children: [
              ListTile(
              title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   SizedBox(
                       height: 50,
                       child: Image.asset("assets/images/logo.png")
                   ),
                  const SizedBox(height: 8),
                  const Text(
                    "Smart pos",
                    style: TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Get.to(const Home()) ;
                    },
                    child: LeftDrawerListTile(
                      const Icon(Icons.table_bar, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  LeftDrawerListTile(
                    const Icon(Icons.fastfood_outlined, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  LeftDrawerListTile(
                    const Icon(Icons.monetization_on_outlined, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          // Middle column (biggest)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TableGridView(),
            ),
          ),
          // Third column
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueGrey,
              child: const Center(
                child: Text('Column 3'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
