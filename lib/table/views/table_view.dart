import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/room/controllers/room_controller.dart';

class TableView extends StatelessWidget {
  final RoomController roomController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: List.generate(
          roomController.roomList.length,
          (index) => Obx(() {
            if (roomController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 30.0,
                    crossAxisSpacing: 30.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: roomController.tableList.length,
                  itemBuilder: (context, index) {
                    final table = roomController.tableList[index];
                    Color borderColor;
                    if ( table.active) {
                      borderColor = AppTheme.lightTheme.primaryColor;
                    } else {
                      borderColor = Colors.blueGrey;
                    }
                    return GestureDetector(
                      onTap: () {
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'T ${table.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
