import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/supplement/models/supplement.dart';
import 'package:pos/table/controllers/table_controller.dart';

class TabContent extends StatefulWidget {
  final Map<Item, int> orderMap;
  final double Function(Map<Item, int>) calculateTotal;
  final String? selectedTableId;
  Map<Item, String> itemNotes = {};

  TabContent({
    required this.orderMap,
    required this.calculateTotal,
    required this.selectedTableId,
  });

  @override
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  final CounterController counterController = Get.put(CounterController());
  final TableController tableController = Get.find();
  final OrderController orderController = Get.find();

  Map<Item, String> itemNotes = {};

  List<OrderItem> getOrderItemsFromMap(Map<Item, int> orderMap, int orderId) {
    return orderMap.entries.map((entry) {
      final item = entry.key;
      final quantity = entry.value;
      final note = itemNotes[item] ?? '';
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
        await tableController.updateTable(widget.selectedTableId!);
        List<OrderItem> orderItems = getOrderItemsFromMap(
            widget.orderMap, counterController.counter.value);

        Order order = Order(
          tableId: int.parse(widget.selectedTableId!),
          total: widget.calculateTotal(widget.orderMap),
          orderItems: orderItems,
          cooking: 'in progress',
          id: counterController.counter.value,
          createdAt: DateTime.now(),
        );

        print('Order Details:');
        print('  Table ID: ${order.tableId}');
        print('  Total: ${order.total}');
        print('  Cooking Status: ${order.cooking}');
        print('  Order ID: ${order.id}');
        print('  Order Items: ${order.orderItems.length}');
        for (var orderItem in order.orderItems) {
          print('    Item: ${orderItem.name}');
          print('      Quantity: ${orderItem.quantity}');
          print('      Price: ${orderItem.price}');
          print('      Note: ${orderItem.note}');
          if (orderItem.selectedSupplements != null) {
            for (var supplement in orderItem.selectedSupplements!) {
              print('      Supplement: ${supplement['name']}');
              print('        Price: ${supplement['price']}');
            }
          }
        }
        await orderController.addOrder(order);
        setState(() {
          widget.orderMap.clear();
        });
      }
    }
  }

  void _showOrderAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attention'),
          content: Text(
              'Veuillez sélectionner des produits pour passer une commande'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final RoomController _roomController = Get.put(RoomController());
    final subTotal = widget.calculateTotal(widget.orderMap);
    double totalPrice = 0;

    return Expanded(
      child: Obx(() {
        if (_roomController.isLoading.value ||
            tableController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Commande N° #00${counterController.counter}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Table N° : ${widget.selectedTableId}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: widget.orderMap.isEmpty
                    ? ListView(
                        children: [
                          Text(
                            'Aucun Produit ! Sélectionnez les produits pour passer une commande ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                        ],
                      )
                    : ListView.builder(
                        itemCount: widget.orderMap.length,
                        itemBuilder: (context, index) {
                          final item = widget.orderMap.keys.elementAt(index);
                          final quantity = widget.orderMap[item];
                          final price = item.price;
                          totalPrice = price * quantity!;
                          final note = itemNotes[item] ?? '';
                          final supplements = item.supplements ?? [];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.name,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              '${(totalPrice).toStringAsFixed(2)} dt',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Qte:'),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.remove,
                                                    size: 15,
                                                    color: const Color.fromARGB(
                                                        255, 142, 107, 3),
                                                  ),
                                                  onPressed: () {
                                                    if (quantity > 1) {
                                                      setState(() {
                                                        widget.orderMap[item] =
                                                            quantity - 1;
                                                      });
                                                    }
                                                  },
                                                ),
                                                Text(
                                                  ' $quantity',
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.add,
                                                    size: 15,
                                                    color: const Color.fromARGB(
                                                        255, 142, 107, 3),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      widget.orderMap[item] =
                                                          quantity + 1;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    String tempNote = note;
                                                    return AlertDialog(
                                                      title: Text(note.isEmpty
                                                          ? 'Ajouter une note'
                                                          : 'Modifier la note'),
                                                      content: TextField(
                                                        onChanged: (value) {
                                                          tempNote = value;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Saisissez votre note',
                                                        ),
                                                        controller:
                                                            TextEditingController(
                                                                text: note),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              itemNotes[item] =
                                                                  tempNote;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('Ok'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                note.isEmpty
                                                    ? 'ajouter note'
                                                    : 'note',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 14, 106, 182),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Suppléments:',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          Flexible(
                                            child: Wrap(
                                              direction: Axis.horizontal,
                                              spacing: 6,
                                              runSpacing: 3,
                                              children:
                                                  supplements.map((supplement) {
                                                return Chip(
                                                  label: Text(
                                                    supplement.name,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      //  overflow:
                                                      //TextOverflow.ellipsis,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 229, 159, 85),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    side: BorderSide(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onDeleted: () {
                                                    _handleSupplementRemove(
                                                        context,
                                                        item,
                                                        supplement);
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sous-total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${subTotal.toStringAsFixed(2)} dt'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade300),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${subTotal.toStringAsFixed(2)} dt'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _handleOrderSubmit(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color.fromARGB(255, 221, 136, 9),
                              backgroundColor: Color.fromARGB(255, 221, 136, 9),
                            ),
                            child: const Text(
                              'Commander',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.orderMap.clear();
                          itemNotes.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        'Supprimer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.orderMap.isNotEmpty) {
                          setState(() {
                            counterController.increment();
                          });
                        } else {
                          _showOrderAlert(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppTheme.lightTheme.primaryColor,
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                      ),
                      child: const Text(
                        'Payer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
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
