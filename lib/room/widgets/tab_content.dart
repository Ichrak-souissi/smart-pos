import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/table/controllers/table_controller.dart';

class TabContent extends StatefulWidget {
  final Map<Item, int> orderMap;
  final double Function(Map<Item, int>) calculateTotal;
  String? selectedTableId;

  TabContent({
    required this.orderMap,
    required this.calculateTotal,
    required this.selectedTableId,
  });

  @override
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  int orderCounter = 1;
  final CounterController counterController = Get.put(CounterController());
  final TableController tableController = Get.put(TableController());
  final OrderController orderController = Get.put(OrderController());

  Map<Item, String> itemNotes = {}; 

  @override
  void initState() {
    super.initState();
  }

   List<OrderItem> getOrderItemsFromMap(Map<Item, int> orderMap) {
    List<OrderItem> orderItems = [];
     widget.orderMap.entries.forEach((entry) {
            final item = entry.key;
            final quantity = entry.value;
            final totalPrice = item.price * quantity;
            final note = itemNotes[item] ?? '';

            final orderItem = OrderItem(
              name: item.name,
              quantity: quantity,
              price: totalPrice,
              note: note,
            );
                print('OrderItem: ${orderItem.name}, Quantity: ${orderItem.quantity}, Price: ${orderItem.price}, Note: ${orderItem.note}');

                orderItems.add(orderItem);
                    print ('$orderItems');



    });

    return orderItems;
  }

  void _handleOrderSubmit() async {
    try {
      if (widget.orderMap.isEmpty) {
        _showOrderAlert();
      } else {
        if (widget.selectedTableId != null) {
          await tableController.updateTable(widget.selectedTableId!);

          List<OrderItem> orderItems = getOrderItemsFromMap(widget.orderMap);
          Order order = Order(
             tableId: int.parse(widget.selectedTableId!),
            total: widget.calculateTotal(widget.orderMap),
            orderItems: orderItems,
            cooking: 'in progress', 
              id:counterController.counter.value,

          );
        print('Objet Order créé: $order');
         print('tableId: ${order.tableId}');
        print('total: ${order.total}');
        print('orderItems: ${order.orderItems}');
        print('cooking: ${order.cooking}');
        print('id: ${order.id}');

          await orderController.addOrder(order);

          setState(() {
            widget.orderMap.clear();
            widget.selectedTableId = null;
          });
        }
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  void _showOrderAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attention'),
          content: Text('Veuillez sélectionner des produits pour passer une commande'),
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

    return Expanded(
      child: Obx(() {
        if (_roomController.isLoading.value || tableController.isLoading.value) {
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
              Divider(color: Colors.grey.shade100,),
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
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          ...widget.orderMap.entries.map((entry) {
                            final item = entry.key;
                            final price = item.price;
                            final quantity = entry.value;
                            final totalPrice = price * quantity;
                            final note = itemNotes[item] ?? '';

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
                                child: ListTile(
                                  title: Text(
                                    item.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    'Qte: $quantity',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${(totalPrice).toStringAsFixed(2)} dt',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 5,),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              String tempNote = note;
                                              return AlertDialog(
                                                title: Text(note.isEmpty ? 'Ajouter une note' : 'Modifier la note'),
                                                content: TextField(
                                                  onChanged: (value) {
                                                    tempNote = value;
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: 'Saisissez votre note',
                                                  ),
                                                  controller: TextEditingController(text: note),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Annuler'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        itemNotes[item] = tempNote;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Ajouter'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          note.isEmpty ? 'ajouter note' : 'note',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 14, 106, 182),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
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
                          Text('${subTotal.toStringAsFixed(2)} dt'), // Limiter à deux décimales
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade300,),
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
                          Text('${(subTotal).toStringAsFixed(2)} dt'),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (widget.orderMap.isEmpty) {
                                _showOrderAlert();
                              } else {
                                _handleOrderSubmit();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color.fromARGB(255, 221, 136, 9),
                              backgroundColor: Color.fromARGB(255, 221, 136, 9),
                            ),
                            child: const Text(
                              'Commander ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.orderMap.clear();
                          widget.selectedTableId = null;
                          itemNotes.clear(); // Réinitialiser les notes lors de la suppression
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        'Supprimer ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.orderMap.isEmpty) {
                          _showOrderAlert();
                        } else {
                          setState(() {
                            counterController.increment();
                          });
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
