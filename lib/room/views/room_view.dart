import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/room/views/reservation_view.dart';

class RoomView extends StatefulWidget {
  const RoomView({Key? key}) : super(key: key);

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  final RoomController roomController = Get.put(RoomController());

  int selectedRoomIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRoomTables();
  }

  void _loadRoomTables() async {
    await roomController.getRoomList();
    if (roomController.roomList.isNotEmpty) {
      await roomController.getTablesByRoomId(roomController.roomList[0].id);
      setState(() {
        selectedRoomIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: roomController.roomList.length,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                     Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bienvenue',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      const SizedBox(width: 80),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {});
                                    },
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 30,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade500,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300,
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.search, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, color: Colors.blueGrey, size: 10),
                      SizedBox(width: 9),
                      Text(
                        'Disponible',
                        style: TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.circle, color: Colors.redAccent, size: 10),
                      SizedBox(width: 10),
                      Text(
                        'Reservé',
                        style: TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.circle, color: AppTheme.lightTheme.primaryColor, size: 10),
                      SizedBox(width: 10),
                      Text(
                        'Occupé',
                        style: TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: AppTheme.lightTheme.primaryColor,
                        indicatorColor: AppTheme.lightTheme.primaryColor,
                        tabs: List.generate(
                          roomController.roomList.length,
                          (index) => Tab(
                            text: roomController.roomList[index].name,
                          ),
                        ),
                        onTap: (index) async {
                          setState(() {
                            selectedRoomIndex = index;
                          });
                          await roomController.getTablesByRoomId(roomController.roomList[index].id);
                        },
                      ),
                    ),
                    Expanded(
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
                                    crossAxisCount: 6,
                                    mainAxisSpacing: 50.0,
                                    crossAxisSpacing: 50.0,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemCount: roomController.tableList.length,
                                  itemBuilder: (context, index) {
                                    final table = roomController.tableList[index];
                                   Color borderColor;
                                if (table.reserved && table.active) {
                                  borderColor = Colors.redAccent;
                                } else if (table.active) {
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
                                            'Table ${table.id}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
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
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: ReservationView(), // Votre vue de réservation
              ),
            ],
          ),
        ),
      ),
    );
  }
}
