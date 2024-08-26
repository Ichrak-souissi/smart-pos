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
  final RxMap<Item, int> orderMap;
  final double Function(Map<Item, int>) calculateTotal;
  final String? selectedTableId;
  final RxMap<Item, String> itemNotes = RxMap<Item, String>();

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
  late final TableController tableController;
  late final OrderController orderController;
  final RoomController roomController = Get.put(RoomController());
  final CounterController counterController = Get.put(CounterController());

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

      double itemTotalPrice = item.price * quantity;
      double supplementsTotalPrice = supplements.fold(
        0.0,
        (sum, supplement) => sum + (supplement.price * quantity),
      );

      return OrderItem(
        categoryId: item.categoryId,
        imageUrl: item.imageUrl,
        orderId: orderId,
        id: item.id,
        name: item.name,
        quantity: quantity,
        price: itemTotalPrice,
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

  void _handleSupplementRemove(Item item, Supplement supplement) {
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
        final subTotal = widget.calculateTotal(widget.orderMap);
        final tax = subTotal * 0.05;
        final total = subTotal + tax;

        await tableController.updateTable(widget.selectedTableId!, true);

        List<OrderItem> orderItems = getOrderItemsFromMap(
            widget.orderMap, counterController.counter.value);

        Order order = Order(
          tableId: int.parse(widget.selectedTableId!),
          total: total,
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

        Navigator.pop(context);
      }
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
      if (newQuantity <= 0) {
        widget.orderMap.remove(item);
      } else {
        widget.orderMap[item] = newQuantity;
      }
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
    final tax = subTotal * 0.05;
    final total = subTotal + tax;

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
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
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
                    ? Center(
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
                          final supplementsTotalPrice = item.supplements?.fold(
                                0.0,
                                (sum, supplement) => sum + supplement.price,
                              ) ??
                              0.0;

                          final totalPrice =
                              (item.price + supplementsTotalPrice) * quantity;

                          final note = widget.itemNotes[item] ?? '';
                          final supplements = item.supplements ?? [];

                          return Dismissible(
                            key: ValueKey(item.id),
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
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        leading: item.imageUrl != null
                                            ? CircleAvatar(
                                                radius: 30,
                                                backgroundImage:
                                                    NetworkImage(item.imageUrl),
                                              )
                                            : const CircleAvatar(
                                                radius: 30,
                                                child:
                                                    Icon(Icons.image, size: 30),
                                              ),
                                        title: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Prix : ${(item.price * quantity).toStringAsFixed(2)} dt',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        _updateItemQuantity(
                                                            item, quantity - 1);
                                                      },
                                                      icon: const Icon(
                                                        Icons.remove_circle,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        _updateItemQuantity(
                                                            item, quantity + 1);
                                                      },
                                                      icon: const Icon(
                                                        Icons.add_circle,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Note:',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: TextField(
                                                    onChanged: (newNote) =>
                                                        _updateItemNote(
                                                            item, newNote),
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(8),
                                                        ),
                                                      ),
                                                      hintText:
                                                          'Ajouter une note',
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 8),
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                    maxLines: null,
                                                    minLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (item.supplements != null &&
                                          item.supplements!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Suppléments:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Wrap(
                                                spacing: 4.0,
                                                runSpacing: 2.0,
                                                children: item.supplements!
                                                    .map((supplement) {
                                                  return Chip(
                                                    label: Text(
                                                      '${supplement.name}',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    deleteIcon: const Icon(
                                                      Icons.remove,
                                                      color: Colors.black,
                                                    ),
                                                    onDeleted: () =>
                                                        _handleSupplementRemove(
                                                            item, supplement),
                                                    backgroundColor:
                                                        Colors.grey.shade50,
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 170, 174, 171),
                        AppTheme.lightTheme.primaryColor
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sous-total',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${subTotal.toStringAsFixed(2)} dt',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Taxe(5%)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${tax.toStringAsFixed(2)} dt',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} dt',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleOrderSubmit(context),
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.white),
                          label: const Text(
                            'Confirmer la commande',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor:
                                const Color.fromARGB(255, 91, 128, 93),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
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
