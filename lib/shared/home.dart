import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/table/views/table_grid_view.dart';
import 'package:pos/table/widgets/left_drawer_list_tile.dart';

import '../authentication/controllers/auth_controller.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.only(left: 10, top: 10),
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text(
                      "Smart pos",
                      style: TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Image.asset("assets/images/cutlery.png"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      //Get.to() ,
                    },
                    child: LeftDrawerListTile(
                        "Tables", const Icon(Icons.table_bar)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  LeftDrawerListTile("food", const Icon(Icons.fastfood_outlined)),
                  const SizedBox(
                    height: 15,
                  ),
                  LeftDrawerListTile("bills", const Icon(Icons.monetization_on_outlined)),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
          // Middle column (biggest)
          const Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.all(20),
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
