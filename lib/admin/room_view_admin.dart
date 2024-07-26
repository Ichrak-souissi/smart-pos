import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/room/models/room.dart';
import 'package:pos/room/widgets/appbar_widget.dart';
import 'package:pos/table/models/table.dart' as Table;
import 'package:pos/table/views/table_detail_dialog.dart';
import 'package:pos/table/widgets/cicular_table.dart';

class RoomViewAdmin extends StatefulWidget {
  const RoomViewAdmin({Key? key}) : super(key: key);

  @override
  State<RoomViewAdmin> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomViewAdmin> {
  final RoomController roomController = Get.put(RoomController());
  final OrderController orderController = Get.put(OrderController());

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

  Future<void> _onRoomChanged(int index) async {
    await roomController.getTablesByRoomId(
      roomController.roomList[index].id,
    );
    setState(() {});
  }

  Future<void> _loadRoomTables(int roomId) async {
    await roomController.getTablesByRoomId(roomId);
  }

  Future<void> _loadOrdersAndItemsByTableId(int tableId) async {
    try {
      ordersForSelectedTable.assignAll(orderController.orders
          .where((order) => order.tableId == tableId)
          .toList());
    } catch (e) {
      print('Error loading orders and items: $e');
    }
  }

  void _showAddTableDialog() {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Ajouter une table'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              content: Form(
                key: _formKey,
                child: Column(
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
                      decoration: const InputDecoration(
                        hintText: 'Sélectionner une salle',
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Sélectionnez une salle';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: tableCapacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Capacité de la table',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez la capacité de la table';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: tablePositionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Position',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez la position de la table';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Ajouter',
                    style: TextStyle(color: AppTheme.lightTheme.primaryColor),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      int newPosition =
                          int.tryParse(tablePositionController.text) ?? 0;

                      bool positionExists = roomController.tableList.any(
                          (table) =>
                              table.position == newPosition &&
                              table.roomId ==
                                  roomController
                                      .roomList[selectedRoomIndex].id);

                      int tableCountInRoom = roomController
                          .roomList[selectedRoomIndex].tables.length;

                      int maxTablesInRoom = roomController
                          .roomList[selectedRoomIndex].numberOfTables;

                      if (positionExists) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Erreur'),
                              content: const Text(
                                  'Une table existe déjà à cette position.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else if (tableCountInRoom < maxTablesInRoom) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Erreur'),
                              content: Text(
                                'Le nombre de tables dans la salle ${roomController.roomList[selectedRoomIndex].name} a atteint la limite maximale.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
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
                        roomController.tableList.add(table);
                        roomController.addTable(table);
                        setState(() {
                          roomController.roomList[selectedRoomIndex].tables
                              .add(table);
                        });
                        tableCountInRoom++;
                        Navigator.of(context).pop();
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
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une salle'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: roomNameController,
                  decoration: const InputDecoration(
                    hintText: 'Nom de la salle',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entrez le nom de la salle';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: numberOfTablesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de tables',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entrez le nombre de tables';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ajouter',
                style: TextStyle(color: AppTheme.lightTheme.primaryColor),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
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
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteRoomDialog(Room room) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la salle'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer la salle ${room.name} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await roomController.deleteRoom(room);
                _loadRoomTables(room.id);
                Navigator.of(context).pop();

                Get.snackbar(
                  'Succès',
                  'La salle ${room.name} a été supprimée avec succès.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        const Spacer(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...roomController.roomList
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                Room room = entry.value;
                                bool isSelected = index == selectedRoomIndex;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRoomIndex = index;
                                      _onRoomChanged(index);
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.lightTheme.primaryColor
                                          : Colors.white,
                                      border: Border.all(
                                        color: AppTheme.lightTheme.primaryColor,
                                        width: isSelected ? 0 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          room.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (isSelected)
                                          GestureDetector(
                                            onTap: () =>
                                                _showDeleteRoomDialog(room),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              GestureDetector(
                                onTap: _showAddRoomDialog,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  padding: const EdgeInsets.all(7.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: AppTheme.lightTheme.primaryColor,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: AppTheme.lightTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Row(
                      children: [],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (roomController.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 2.0,
                              crossAxisSpacing: 2.0,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: roomController.tableList.length,
                            itemBuilder: (context, index) {
                              final table = roomController.tableList[index];
                              Color borderColor;
                              if (table.active) {
                                borderColor =
                                    const Color.fromARGB(255, 101, 210, 105);
                              } else {
                                borderColor =
                                    const Color.fromARGB(255, 127, 150, 161);
                              }
                              return GestureDetector(
                                onTap: () {
                                  if (table.active) {
                                    setState(() {
                                      selectedTable = table;
                                      TableDetailsDialog(
                                        context,
                                        ordersForSelectedTable,
                                      ).show(selectedTable);
                                      _loadOrdersAndItemsByTableId(
                                          selectedTable.id);
                                    });
                                  }
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
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTableDialog,
        tooltip: 'Ajouter une table',
        child: const Icon(Icons.add),
      ),
    );
  }
}
