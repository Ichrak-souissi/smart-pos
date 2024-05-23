import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/ingredient/models/ingredient.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/table/controllers/table_controller.dart';
import 'package:pos/supplement/models/supplement.dart';

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
  final OrderItemController orderItemController = Get.put(OrderItemController());

  @override
  void initState() {
    super.initState();
    TableController();
  }

Future<void> _handleOrderSubmit() async {
  try {
    if (widget.orderMap.isEmpty) {
      _showOrderAlert();
    } else {
      await addOrderItemFromMap(widget.orderMap);
      await tableController.updateTable(widget.selectedTableId.toString());
    }
  } catch (e) {
    print("Error submitting order: $e");
  }
}


Future<void> addOrderItemFromMap(Map<Item, int> orderMap) async {
  for (final entry in orderMap.entries) {
    final item = entry.key;
    final quantity = entry.value;
    final totalPrice = item.price * quantity;

    final selectedIngredients = item.ingredients;
     for (var ingredient in selectedIngredients) {
        print(' - ${ingredient.name}');
        print(' - ${ingredient.itemId}');
        print(' - ${ingredient.active}');
      }
    final selectedSupplements = item.supplements;
 for (var supplement in selectedSupplements) {
        print(' - ${supplement.name}');
        print(' - ${supplement.itemId}');
        print(' - ${supplement.price}');
      }
    final orderItem = OrderItem(
      orderId: counterController.counter.value,
      name: item.name,
      quantity: quantity,
      price: totalPrice,
      ingredients: selectedIngredients,
      supplements: selectedSupplements,
    );
    await orderItemController.addOrderItem(orderItem);
  }
}


  void _showOrderAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attention'),
        content: Text('Veuillez sélectionner des produits pour passer une commande'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final RoomController _roomController = Get.put(RoomController());
    final subTotal = widget.calculateTotal(widget.orderMap);

    return Expanded(
      child: Obx(() {
        if (_roomController.isLoading.value || tableController.isLoading.value) {
          return const Center(
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
                      final selectedIngredients = item.ingredients;
                      print(selectedIngredients);
                      final selectedSupplements = item.supplements;
                      print(selectedSupplements);
             
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
                          child: Stack(
                            children: [
                              ListTile(
                                title: Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Qte: $quantity',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: Text(
                                  '${(totalPrice).toStringAsFixed(2)} dt',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.orderMap.remove(item);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                setState(() {
                                  widget.orderMap.clear();
                                  widget.selectedTableId = null;
                                  counterController.increment(); 
                               
                                });
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
