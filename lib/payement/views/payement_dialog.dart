import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/payement/widgets/calculator_widget.dart';

class PaymentDialog extends StatefulWidget {
  final List<Order> ordersForSelectedTable;
  final RoomController roomController;
  final int selectedRoomIndex;
  final int tableId;

  PaymentDialog({
    required this.ordersForSelectedTable,
    required this.roomController,
    required this.selectedRoomIndex,
    required this.tableId,
  });

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late List<Order> ordersForSelectedTable;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    ordersForSelectedTable = widget.ordersForSelectedTable;
    totalAmount = _calculateTotalAmount();
  }

  double _calculateTotalAmount() {
    return ordersForSelectedTable.fold(
      0.0,
      (sum, order) => sum + order.total,
    );
  }

  void _onOrderDismissed(Order order) async {
    final OrderController orderController = Get.find<OrderController>();

    await orderController.deleteOrder(order.id.toString());
    setState(() {
      ordersForSelectedTable.remove(order);
      totalAmount = _calculateTotalAmount();
    });
    widget.roomController.update();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          SizedBox(
            width: screenWidth * 0.9,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            child: CalculatorWidget(
                              orderTotal: totalAmount,
                              orders: ordersForSelectedTable,
                              tableId: widget.tableId,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16.0),
                                color: Color.fromARGB(255, 215, 228, 217),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Les commandes',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (ordersForSelectedTable.isEmpty) ...[
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              'Aucune commande',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        ...ordersForSelectedTable.map((order) =>
                                            Dismissible(
                                              key: Key(order.id.toString()),
                                              direction:
                                                  DismissDirection.endToStart,
                                              onDismissed: (direction) {
                                                _onOrderDismissed(order);
                                              },
                                              background: Container(
                                                color: Colors.red,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
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
                                                          'Commande N°${order.id}',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${order.total.toStringAsFixed(2)} TND',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Date: ${order.createdAt.toLocal().toString().substring(0, 16)}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      'Articles:',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Column(
                                                      children: [
                                                        ...order.orderItems
                                                            .map(
                                                                (item) =>
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              8.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            child:
                                                                                Image.network(
                                                                              item.imageUrl,
                                                                              width: 60,
                                                                              height: 60,
                                                                              fit: BoxFit.cover,
                                                                              errorBuilder: (context, error, stackTrace) {
                                                                                return Container(
                                                                                  width: 60,
                                                                                  height: 60,
                                                                                  color: Colors.grey[300],
                                                                                  child: Icon(
                                                                                    Icons.error,
                                                                                    color: Colors.red,
                                                                                    size: 28,
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 12),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  '${item.quantity} x ${item.name}',
                                                                                  style: TextStyle(fontSize: 16),
                                                                                ),
                                                                                SizedBox(height: 4),
                                                                                Text(
                                                                                  '${item.price.toStringAsFixed(2)} TND',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color.fromARGB(255, 99, 104, 147),
                                                                                  ),
                                                                                ),
                                                                                if (item.note.isNotEmpty) ...[
                                                                                  SizedBox(height: 6),
                                                                                  Text(
                                                                                    'Note: ${item.note}',
                                                                                    style: TextStyle(
                                                                                      fontSize: 12,
                                                                                      fontStyle: FontStyle.italic,
                                                                                      color: Colors.grey[600],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                                if (item.selectedSupplements.isNotEmpty) ...[
                                                                                  SizedBox(height: 6),
                                                                                  Text(
                                                                                    'Suppléments:',
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Colors.grey[800],
                                                                                    ),
                                                                                  ),
                                                                                  ...item.selectedSupplements.map(
                                                                                    (supplement) => Text(
                                                                                      '${supplement['name']} - ${supplement['price']} TND',
                                                                                      style: TextStyle(
                                                                                        fontSize: 12,
                                                                                        color: Colors.grey[600],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ],
                                      SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(16.0),
                                color: Colors.grey[200],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      '${totalAmount.toStringAsFixed(2)} TND',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 99, 104, 147),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: _closeDialog,
            ),
          ),
        ],
      ),
    );
  }
}
