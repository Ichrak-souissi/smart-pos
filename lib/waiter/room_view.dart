import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/payement/views/calculator_widget.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/room/widgets/appbar_widget.dart';
import 'package:pos/room/widgets/order_widget.dart';
import 'package:pos/table/controllers/table_controller.dart';
import 'package:pos/table/models/table.dart' as pos_table;
import 'package:pos/table/widgets/cicular_table.dart';

class RoomView extends StatefulWidget {
  const RoomView({super.key});

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  final RoomController roomController = Get.put(RoomController());
  final OrderController orderController = Get.put(OrderController());
  final OrderItemController orderItemController =
      Get.put(OrderItemController());
  int selectedRoomIndex = 0;
  pos_table.Table? selectedTable;
  RxList<Order> ordersForSelectedTable = RxList<Order>();
  RxList<OrderItem> orderItems = RxList<OrderItem>();
  final TableController tableController = Get.put(TableController());
  bool showExpanded = false;

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
            .where((order) => order.tableId == tableId)
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
        selectedRoomIndex = 0;
      });
    }
  }

  void _onTableSelected(pos_table.Table table) {
    setState(() {
      selectedTable = table;
      showExpanded = false;
    });
    _loadOrdersAndItemsByTableId(selectedTable!.id);
    if (table.active) {
      _showOptionsDialog(context);
    } else
      _showOrderDialog();
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
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
                    showExpanded = true;
                  });
                },
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: Icon(
                  selectedTable!.active ? Icons.lock : Icons.lock_open,
                  color: Colors.redAccent,
                  size: 28,
                ),
                title: Text(
                  selectedTable!.active ? 'Table occupée' : 'Table disponible',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Switch(
                  value: !selectedTable!.active,
                  onChanged: (bool value) {
                    Navigator.of(context).pop();
                    setState(() {
                      selectedTable!.active = !value;
                    });
                    tableController.updateTable(
                        selectedTable!.id.toString(), !value);
                  },
                ),
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
            selectedTableId: selectedTable!.id,
          ),
        );
      },
    );
  }

  void _showPaymentDialog() {
    double orderTotal = orderItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalculatorWidget(
          orderTotal: orderTotal,
          orders: ordersForSelectedTable,
        );
      },
    );
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
                    AppBarWidget(),
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
                              color: Color(0xFF00A86B), size: 15),
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
                            selectedRoomIndex = index;
                            selectedTable = null;
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
                                        ? Color(0xFF65D265)
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
              if (selectedTable != null &&
                  selectedTable!.active &&
                  showExpanded)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(6),
                            child: Text(
                              'Table N°${selectedTable!.position}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Capacité:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${selectedTable!.capacity}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Icon(Icons.person, size: 20),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'État:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                selectedTable!.active ? 'Occupé' : 'Disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedTable!.active
                                      ? AppTheme.lightTheme.primaryColor
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Divider(color: Colors.grey[300]),
                          Expanded(
                            child: ListView(
                              children: [
                                for (var order in ordersForSelectedTable)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Commande N°${order.id}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Date: ${order.createdAt.toLocal().toString().substring(0, 16)}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Articles:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            for (var item in orderItems.where(
                                                (item) =>
                                                    item.orderId == order.id))
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 3.0),
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${item.quantity} x ${item.name}',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                        Text(
                                                          '${item.price} TND',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (item
                                                        .note.isNotEmpty) ...[
                                                      SizedBox(height: 5),
                                                      Text(
                                                        'Note: ${item.note}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                    if (item.selectedSupplements
                                                        .isNotEmpty) ...[
                                                      SizedBox(height: 5),
                                                      Text(
                                                        'Suppléments:',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      for (var supplement in item
                                                          .selectedSupplements)
                                                        Text(
                                                          '${supplement['name']} - ${supplement['price']} TND',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 10),
                              Flexible(
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      double orderTotal = orderItems.fold(
                                        0,
                                        (sum, item) =>
                                            sum + (item.price * item.quantity),
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CalculatorWidget(
                                            orderTotal: orderTotal,
                                            orders: ordersForSelectedTable,
                                          );
                                        },
                                      );
                                      setState(() {
                                        showExpanded = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                    ),
                                    child: Text(
                                      'Payer pour ${ordersForSelectedTable.fold(
                                            0.0,
                                            (sum, order) =>
                                                sum +
                                                orderItems
                                                    .where((item) =>
                                                        item.orderId ==
                                                        order.id)
                                                    .fold(
                                                      0.0,
                                                      (orderSum, item) =>
                                                          orderSum +
                                                          (item.price *
                                                              item.quantity),
                                                    ),
                                          ).toStringAsFixed(2)} TND',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
