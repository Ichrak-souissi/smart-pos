import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/room/models/room.dart';
import 'package:pos/room/widgets/appbar_widget.dart';
import 'package:pos/table/widgets/cicular_table.dart';
import 'package:pos/table/models/table.dart' as Table;

class RoomViewAdmin extends StatefulWidget {
  const RoomViewAdmin({Key? key}) : super(key: key);

  @override
  State<RoomViewAdmin> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomViewAdmin> {
  final RoomController roomController = Get.put(RoomController());
  final OrderController orderController = Get.put(OrderController());
  final OrderItemController orderItemController =
      Get.put(OrderItemController());

  int selectedRoomIndex = 0;
  var selectedTable;
  RxList<Order> ordersForSelectedTable = RxList<Order>();
  RxList<OrderItem> orderItems = RxList<OrderItem>();

  TextEditingController roomNameController = TextEditingController();
  TextEditingController numberOfTablesController = TextEditingController();
  TextEditingController tableCapacityController = TextEditingController();
  TextEditingController tablePositionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await roomController.getRoomList();
    if (roomController.roomList.isNotEmpty) {
      await _loadRoomTables(roomController.roomList[0].id);
      setState(() {
        selectedRoomIndex = 0;
      });
    }
  }

  Future<void> _loadRoomTables(int roomId) async {
    await roomController.getTablesByRoomId(roomId);
  }

  Future<void> _loadOrdersAndItemsByTableId(int tableId) async {
    try {
      await orderController.fetchOrdersByTableId(tableId.toString());
      ordersForSelectedTable.assignAll(orderController.orders
          .where((order) => order.tableId == tableId)
          .toList());

      List<OrderItem> loadedOrderItems = [];
      for (var order in ordersForSelectedTable) {
        await orderItemController.fetchOrderItemsByOrderId(order.id.toString());
        loadedOrderItems.addAll(orderItemController.orderItems);
      }

      orderItems.assignAll(loadedOrderItems);
      orderItems.forEach((orderItem) {
        print(
            'Order Item: ${orderItem.name}, Quantity: ${orderItem.quantity}, Price: ${orderItem.price}, Note: ${orderItem.note}');
      });
    } catch (e) {
      print('Error loading orders and items: $e');
    }
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Ajouter une table'),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: roomController.roomList[selectedRoomIndex].id,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedRoomIndex = roomController.roomList
                            .indexWhere((room) => room.id == newValue);
                      });
                    },
                    items: roomController.roomList
                        .map((Room room) => DropdownMenuItem<int>(
                              value: room.id,
                              child: Text(room.name),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      hintText: 'Sélectionner une salle',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: tableCapacityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Capacité de la table',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: tablePositionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Position',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Ajouter'),
                  onPressed: () async {
                    int newPosition =
                        int.tryParse(tablePositionController.text) ?? 0;

                    bool positionExists = roomController.tableList.any(
                        (table) =>
                            table.position == newPosition &&
                            table.roomId ==
                                roomController.roomList[selectedRoomIndex].id);

                    if (positionExists) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Erreur'),
                            content:
                                Text('Une table existe déjà à cette position.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      var table = Table.Table(
                        capacity:
                            int.tryParse(tableCapacityController.text) ?? 0,
                        active: false,
                        position: newPosition,
                        roomId: roomController.roomList[selectedRoomIndex].id,
                        orders: [],
                        id: 0,
                      );

                      try {
                        roomController.addTable(table);
                        roomController.tableList.add(table);
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Table ajoutée avec succès'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } catch (e) {
                        print('Error adding table: $e');
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une salle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomNameController,
                decoration: InputDecoration(
                  hintText: 'Nom de la salle',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: numberOfTablesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nombre de tables',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                var room = Room(
                  id: roomController.roomList.length + 1,
                  name: roomNameController.text,
                  numberOfTables:
                      int.tryParse(numberOfTablesController.text) ?? 0,
                  tables: [],
                );

                roomController.addRoom(room);
                roomController.roomList.add(room);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Salle ajoutée avec succès'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showTableDetailsDialog(Table.Table table) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          content: Container(
            width: double.minPositive,
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
                          'Table N°${selectedTable.position}',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      if (order.status == 1)
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              flex: 5,
                              child: Center(
                                child: Text(
                                  'Quantité',
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
                      for (var orderItem in orderItems
                          .where((orderItem) => orderItem.orderId == order.id))
                        Column(
                          children: [
                            Card(
                              color: Color.fromARGB(225, 255, 255, 255),
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Center(
                                            child: Text(
                                              '${orderItem.name}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${orderItem.quantity}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
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
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Note'),
                                                      content:
                                                          Text(orderItem.note),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('Fermer'),
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
                                                  color: Color.fromARGB(
                                                      255, 11, 57, 94),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Wrap(
                                      spacing: 2.0,
                                      runSpacing: 2.0,
                                      children: [
                                        for (var supplement
                                            in orderItem.selectedSupplements)
                                          Text(
                                            '+${supplement['name']}',
                                            style: TextStyle(fontSize: 14),
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
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
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
                    AppBarWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
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
                          Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _showAddTableDialog(),
                            label: Text(
                              "Ajouter une table",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 150, 133, 224),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _showAddRoomDialog,
                            label: Text(
                              "Ajouter une salle",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 150, 133, 224),
                            ),
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
                                            _showTableDetailsDialog(
                                                selectedTable);
                                            _loadOrdersAndItemsByTableId(
                                                selectedTable.id);
                                          });
                                        }
                                      },
                                      child: CircularTable(
                                        capacity: table.capacity,
                                        tableName: 'Table N° ${table.position}',
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
