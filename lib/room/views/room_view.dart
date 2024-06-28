import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/room/widgets/order_widget.dart';

class RoomView extends StatefulWidget {
  const RoomView({Key? key}) : super(key: key);

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  final RoomController roomController = Get.put(RoomController());
  final OrderController orderController = Get.put(OrderController());
  final OrderItemController orderItemController =
      Get.put(OrderItemController());
  int selectedRoomIndex = 0;
  var selectedTable;
  List<Order> ordersForSelectedTable = [];
  List<OrderItem> orderItems = [];

  @override
  void initState() {
    super.initState();
    _loadRoomTables();
  }

  Future<void> _loadOrdersAndItemsByTableId(int tableId) async {
    try {
      await orderController.fetchOrdersByTableId(tableId.toString());
      setState(() {
        ordersForSelectedTable = orderController.orders
            .where((order) => order.tableId == tableId)
            .toList();
      });

      List<OrderItem> loadedOrderItems = [];
      for (var order in ordersForSelectedTable) {
        await orderItemController.fetchOrderItemsByOrderId(order.id.toString());
        loadedOrderItems.addAll(orderItemController.orderItems);
      }
      setState(() {
        orderItems = loadedOrderItems;
        orderItems.forEach((orderItem) {
          print(
              'Order Item: ${orderItem.name}, Quantity: ${orderItem.quantity}, Price: ${orderItem.price}, Note: ${orderItem.note}');
        });
      });
    } catch (e) {
      print('Error loading orders and items: $e');
    }
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
                flex: 5,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 140,
                              maxHeight: 100,
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
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
                                              child: Icon(
                                                Icons.search,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PopupMenuButton<String>(
                              icon: FaIcon(
                                FontAwesomeIcons.sliders,
                                color: Colors.black38,
                                size: 20,
                              ),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'alphabet',
                                  child: Text('Tables occupées'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'creationDate',
                                  child: Text('Tables disponibles'),
                                ),
                              ],
                              onSelected: (String value) {
                                setState(() {});
                              },
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
                          const Icon(
                            Icons.circle,
                            color: Color.fromARGB(255, 52, 119, 153),
                            size: 15,
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'Disponible',
                            style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.circle,
                            color: AppTheme.lightTheme.primaryColor,
                            size: 15,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Occupé',
                            style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: Colors.redAccent,
                        labelColor: Colors.redAccent,
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
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    mainAxisSpacing: 20.0,
                                    crossAxisSpacing: 20.0,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemCount: roomController.tableList.length,
                                  itemBuilder: (context, index) {
                                    final table =
                                        roomController.tableList[index];
                                    Color borderColor;
                                    if (table.active) {
                                      borderColor =
                                          AppTheme.lightTheme.primaryColor;
                                    } else {
                                      borderColor = Colors.blueGrey;
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        if (table.active) {
                                          setState(() {
                                            selectedTable = table;
                                          });
                                          _loadOrdersAndItemsByTableId(
                                              selectedTable.id);
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: OrderWidget(
                                                  selectedTableId: table.id,
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: borderColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Table N° ${table.id}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
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
              if (selectedTable != null && selectedTable.active)
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView(
                            children: [
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        'Table N°${selectedTable.id}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Capacité: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${selectedTable.capacity}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Icon(
                                          Icons.person_3_outlined,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'État: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${selectedTable.active ? 'Occupé' : 'Disponible'}',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              for (var order in ordersForSelectedTable)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Commande #000${order.id}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    if (order.cooking.toLowerCase() ==
                                        'in progress')
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Statut: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text('En cours'),
                                          ],
                                        ),
                                      ),
                                    SizedBox(height: 15),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              'Article',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Center(
                                              child: Text(
                                                'Qté',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Center(
                                              child: Text(
                                                'Prix',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Center(
                                              child: Text(
                                                'Note',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    for (var orderItem in orderItems.where(
                                        (orderItem) =>
                                            orderItem.orderId == order.id))
                                      Column(
                                        children: [
                                          Card(
                                            color: Color.fromARGB(
                                                225, 255, 255, 255),
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5.0),
                                            elevation: 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: Center(
                                                          child: Text(
                                                            '${orderItem.name}',
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '${orderItem.quantity}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Center(
                                                          child: Text(
                                                            '${orderItem.price * orderItem.quantity}dt',
                                                            style: TextStyle(
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Center(
                                                          child: InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'Note'),
                                                                    content: Text(
                                                                        orderItem
                                                                            .note),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                            'Fermer'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                              'Note',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        11,
                                                                        57,
                                                                        94),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8),
                                                  child: Row(
                                                    children: [
                                                      for (var supplement
                                                          in orderItem
                                                              .selectedSupplements)
                                                        Text(
                                                          '+${supplement['name']}',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total: ${order.total}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              selectedTable = null;
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 18,
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
