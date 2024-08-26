import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/payement/views/calculator_widget.dart';
import 'package:pos/payement/views/payement_dialog.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/order/views/order_widget.dart';
import 'package:pos/shared/widgets/appbar_widget.dart';
import 'package:pos/table/controllers/table_controller.dart';
import 'package:pos/table/models/table.dart' as pos_table;
import 'package:pos/table/widgets/cicular_table.dart';

class RoomView extends StatefulWidget {
  const RoomView({super.key});

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  RxInt selectedRoomIndex = 0.obs;
  final TableController tableController = Get.put(TableController());
  Rx<pos_table.Table?> selectedTable = Rx<pos_table.Table?>(null);
  RxList<Order> ordersForSelectedTable = RxList<Order>();
  RxList<OrderItem> orderItems = RxList<OrderItem>();
  RxBool showExpanded = false.obs;
  final OrderController orderController = Get.put(OrderController());
  final OrderItemController orderItemController =
      Get.put(OrderItemController());
  final RoomController roomController = Get.put(RoomController());

  @override
  void initState() {
    super.initState();
    _loadRoomTables();
  }

  Future<void> _loadOrdersAndItemsByTableId(int tableId) async {
    try {
      await orderController.fetchOrdersByTableId(tableId.toString());
      ordersForSelectedTable.assignAll(
        orderController.orders
            .where((order) => order.tableId == tableId && order.isPaid == false)
            .toList(),
      );

      List<OrderItem> loadedOrderItems = [];
      for (var order in ordersForSelectedTable) {
        await orderItemController.fetchOrderItemsByOrderId(order.id.toString());
        loadedOrderItems.addAll(orderItemController.orderItems);
      }

      orderItems.assignAll(loadedOrderItems);
      setState(() {});
    } catch (e) {}
  }

  Future<void> _loadRoomTables() async {
    await roomController.getRoomList();
    if (roomController.roomList.isNotEmpty) {
      await roomController.getTablesByRoomId(roomController.roomList[0].id);
      setState(() {
        selectedRoomIndex = 0.obs;
      });
    }
  }

  void _onTableSelected(pos_table.Table table) {
    setState(() {
      selectedTable = table.obs;
      showExpanded = false.obs;
    });
    _loadOrdersAndItemsByTableId(selectedTable.value!.id);
    if (table.active) {
      _showOptionsDialog(context);
    } else if (table.active == false) {
      _showOrderDialog();
    }
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: Icon(Icons.add, color: Colors.green, size: 28),
                title: Text('Passer une autre commande',
                    style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showOrderDialog();
                },
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: Icon(Icons.payment, color: Colors.blue, size: 28),
                title:
                    Text('Payer la commande', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _showPaymentDialog();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: OrderWidget(
            selectedTableId: selectedTable.value!.id,
          ),
        );
      },
    ).then((_) {
      roomController.getTablesByRoomId(
          roomController.roomList[selectedRoomIndex.value].id);
    });
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentDialog(
          ordersForSelectedTable: ordersForSelectedTable,
          roomController: roomController,
          selectedRoomIndex: selectedRoomIndex.value,
          tableId: selectedTable.value!.id,
        );
      },
    ).then((_) {
      roomController.getTablesByRoomId(
          roomController.roomList[selectedRoomIndex.value].id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: roomController.roomList.length,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 255, 245),
        body: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    const AppBarWidget(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.circle,
                              color: Color(0xFF347997), size: 15),
                          SizedBox(width: 9),
                          Text('Disponible', style: TextStyle(fontSize: 15)),
                          SizedBox(width: 10),
                          Icon(Icons.circle,
                              color: AppTheme.lightTheme.primaryColor,
                              size: 15),
                          SizedBox(width: 10),
                          Text('Occupé', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: AppTheme.lightTheme.primaryColor,
                        labelColor: Colors.black,
                        tabs: List.generate(
                          roomController.roomList.length,
                          (index) => Tab(
                            text: roomController.roomList[index].name,
                          ),
                        ),
                        onTap: (index) async {
                          setState(() {
                            selectedRoomIndex.value = index;
                          });
                          await roomController.getTablesByRoomId(
                              roomController.roomList[index].id);
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: List.generate(
                          roomController.roomList.length,
                          (index) => Obx(() {
                            if (roomController.isLoading.value) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    mainAxisSpacing: 5.0,
                                    crossAxisSpacing: 5.0,
                                    childAspectRatio: 1.5,
                                  ),
                                  itemCount: roomController.tableList.length,
                                  itemBuilder: (context, index) {
                                    final table =
                                        roomController.tableList[index];
                                    Color borderColor = table.active
                                        ? Color.fromARGB(255, 52, 183, 59)
                                        : Color(0xFF7F9699);
                                    return GestureDetector(
                                      onTap: () {
                                        _onTableSelected(table);
                                      },
                                      child: CircularTable(
                                        capacity: table.capacity,
                                        tableName: ' ${table.position}',
                                        borderColor: borderColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
