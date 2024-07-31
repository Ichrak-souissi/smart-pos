import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/supplement/models/supplement.dart';
import 'package:pos/table/controllers/table_controller.dart';

// ignore: must_be_immutable
class TabContent extends StatefulWidget {
  final Map<Item, int> orderMap;
  final double Function(Map<Item, int>) calculateTotal;
  final String? selectedTableId;
  Map<Item, String> itemNotes = {};

  TabContent({
    super.key,
    required this.orderMap,
    required this.calculateTotal,
    required this.selectedTableId,
  });

  @override
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  final CounterController counterController = Get.put(CounterController());
  late final TableController tableController;
  late final OrderController orderController;
  final RoomController roomController = Get.put(RoomController());

  @override
  void initState() {
    super.initState();
    tableController = Get.put(TableController());
    orderController = Get.put(OrderController());
  }

  List<OrderItem> getOrderItemsFromMap(Map<Item, int> orderMap, int orderId) {
    return orderMap.entries.map((entry) {
      final item = entry.key;
      final quantity = entry.value;
      final note = widget.itemNotes[item] ?? '';
      final supplements = item.supplements ?? [];
      return OrderItem(
        categoryId: item.categoryId,
        imageUrl: item.imageUrl,
        orderId: orderId,
        id: item.id,
        name: item.name,
        quantity: quantity,
        price: item.price * quantity,
        note: note,
        selectedSupplements: supplements
            .map((supplement) => {
                  'name': supplement.name,
                  'price': supplement.price,
                })
            .toList(),
      );
    }).toList();
  }

  void _handleSupplementRemove(
      BuildContext context, Item item, Supplement supplement) {
    setState(() {
      item.supplements?.remove(supplement);
      item.price -= supplement.price;
    });
  }

  void _handleOrderSubmit(BuildContext context) async {
    if (widget.orderMap.isEmpty) {
      _showOrderAlert(context);
    } else {
      if (widget.selectedTableId != null) {
        // Appel à la méthode pour mettre à jour la table
        await tableController.updateTable(widget.selectedTableId!, true);

        // Appel pour obtenir la liste mise à jour des tables de la chambre sélectionnée
        await roomController
            .getTablesByRoomId(int.parse(widget.selectedTableId!));

        List<OrderItem> orderItems = getOrderItemsFromMap(
            widget.orderMap, counterController.counter.value);

        Order order = Order(
          tableId: int.parse(widget.selectedTableId!),
          total: widget.calculateTotal(widget.orderMap),
          isPaid: false,
          orderItems: orderItems,
          status: 1,
          createdAt: DateTime.now(),
          id: counterController.counter.value,
        );

        await orderController.addOrder(order);
        setState(() {
          widget.orderMap.clear();
        });
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  void _showOrderAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Attention'),
          content: const Text(
              'Veuillez sélectionner des produits pour passer une commande'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _updateItemQuantity(Item item, int newQuantity) {
    setState(() {
      widget.orderMap[item] = newQuantity;
    });
  }

  void _updateItemNote(Item item, String newNote) {
    setState(() {
      widget.itemNotes[item] = newNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subTotal = widget.calculateTotal(widget.orderMap);

    return Expanded(
      child: Obx(() {
        if (roomController.isLoading.value || tableController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Table N° : ${widget.selectedTableId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.grey.shade200),
              Flexible(
                child: widget.orderMap.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun produit sélectionné.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.orderMap.length,
                        itemBuilder: (context, index) {
                          final item = widget.orderMap.keys.elementAt(index);
                          final quantity = widget.orderMap[item]!;
                          final totalPrice = item.price * quantity;
                          final note = widget.itemNotes[item] ?? '';
                          final supplements = item.supplements ?? [];

                          return Dismissible(
                            key: Key(item.id.toString()),
                            onDismissed: (direction) {
                              setState(() {
                                widget.orderMap.remove(item);
                              });
                            },
                            background: Container(
                              color: Colors.red,
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      // Commenté pour ne pas afficher l'image
                                      // leading: item.imageUrl != null
                                      //   ? CircleAvatar(
                                      //       radius: 30,
                                      //       backgroundImage: NetworkImage(item.imageUrl),
                                      //     )
                                      //   : const CircleAvatar(
                                      //       radius: 30,
                                      //       child: Icon(Icons.image, size: 30),
                                      //     ),
                                      leading: const CircleAvatar(
                                        radius: 30,
                                        child: Icon(Icons.image, size: 30),
                                      ),
                                      title: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.remove),
                                                    onPressed: () {
                                                      if (quantity > 1) {
                                                        _updateItemQuantity(
                                                            item, quantity - 1);
                                                      }
                                                    },
                                                  ),
                                                  Text(
                                                    '$quantity',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add),
                                                    onPressed: () {
                                                      _updateItemQuantity(
                                                          item, quantity + 1);
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${totalPrice.toStringAsFixed(2)} dt',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          TextFormField(
                                            initialValue: note,
                                            decoration: const InputDecoration(
                                              labelText: 'Note',
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (newNote) {
                                              _updateItemNote(item, newNote);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (supplements.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SizedBox(
                                          height: 30,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: supplements.length,
                                            itemBuilder: (context, index) {
                                              final supplement =
                                                  supplements[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4.0),
                                                child: Chip(
                                                  label: Text(
                                                    supplement.name,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  side: BorderSide.none,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 231, 29, 69),
                                                  deleteIcon: const Icon(
                                                      Icons.remove,
                                                      color: Colors.white,
                                                      size: 18),
                                                  onDeleted: () {
                                                    _handleSupplementRemove(
                                                        context,
                                                        item,
                                                        supplement);
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${subTotal.toStringAsFixed(2)} dt',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Annuler ',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _handleOrderSubmit(context);
                      roomController.getRoomList();
                    },
                    child: Text(
                      'Passer la commande',
                      style: TextStyle(color: AppTheme.lightTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      }),
    );
  }
}

class CounterController extends GetxController {
  var counter = 1.obs;

  void increment() {
    counter++;
  }

  void reset() {
    counter.value = 1;
  }
}
