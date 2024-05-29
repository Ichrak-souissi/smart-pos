import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order/controllers/order_controller.dart';
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

  int selectedRoomIndex = 0;
  var selectedTable; // Variable to track the selected table

  @override
  void initState() {
    super.initState();
    _loadRoomTables();
  }

  void _loadOrdersByTableId(int tableId) async {
    try {
      await orderController.fetchOrdersByTableId(tableId.toString());
    } catch (e) {
      print('Error fetching orders by table id: $e');
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
                flex: 3,
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
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                          const Icon(Icons.circle, color: Colors.blueGrey, size: 20),
                          const SizedBox(width: 9),
                          const Text(
                            'Disponible',
                            style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.circle, color: AppTheme.lightTheme.primaryColor, size: 20),
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
                                    mainAxisSpacing: 40.0,
                                    crossAxisSpacing: 40.0,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemCount: roomController.tableList.length,
                                  itemBuilder: (context, index) {
                                    final table = roomController.tableList[index];
                                    Color borderColor;
                                    if (table.active) {
                                      borderColor = AppTheme.lightTheme.primaryColor;
                                    } else {
                                      borderColor = Colors.blueGrey;
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        if (table.active) {
                                          setState(() {
                                            selectedTable = table; // Set the selected table
                                          });
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // Si la table est occupée, chargez les commandes associées
                                              _loadOrdersByTableId(table.id); // Appel de la fonction pour charger les commandes
                                              return Dialog(child: OrderWidget(selectedTableId: table.id));
                                            },
                                          );
                                        }
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
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Table N° ${table.id}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
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
              if (selectedTable != null)
  Expanded(
    flex: 1,
    child: Container(
      color: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails de la table N°${selectedTable.id}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Capacité: ${selectedTable.capacity}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'État: ${selectedTable.active ? 'Occupé' : 'Disponible'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Commandes:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                for (var order in orderController.orders)
                  if (order.tableId == selectedTable.id)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande ID: ${order.id}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total: ${order.total}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Statut: ${order.cooking}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Articles de commande:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        for (var item in order.orderItems)
                          ListTile(
                            title: Text('${item.name} (${item.quantity} x ${item.price} DH)'),
                            subtitle: Text(item.note),
                          ),
                        SizedBox(height: 10),
                      ],
                    ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  selectedTable = null;
                });
              },
            ),
          ),
        ],
      ),
    ),
  ),

            ],
          ),
        ),
      ),
    );
  }
}

