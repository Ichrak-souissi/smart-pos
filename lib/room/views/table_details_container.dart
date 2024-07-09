import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order/models/order.dart';

import '../../order-item/models/order-item.dart';

class TableDetailsContainer extends StatelessWidget {
  const TableDetailsContainer({
    Key? key,
    required this.selectedTable,
    required this.ordersForSelectedTable,
    required this.orderItems,
  }) : super(key: key);

  final dynamic selectedTable;
  final RxList<Order> ordersForSelectedTable;
  final RxList<OrderItem> orderItems;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Détails de la Table N°${selectedTable.id}'),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
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
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Etat:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order.status == 1 ? 'Prête' : 'En cours',
                                ),
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
                          for (var orderItem in orderItems.where(
                              (orderItem) => orderItem.orderId == order.id))
                            Column(
                              children: [
                                Card(
                                  color: Color.fromARGB(225, 255, 255, 255),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5.0),
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
                                                  style:
                                                      TextStyle(fontSize: 14),
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
                                                  '${orderItem.price * orderItem.quantity}€',
                                                  style:
                                                      TextStyle(fontSize: 15),
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
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text('Note'),
                                                          content: Text(
                                                              orderItem.note),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
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
                                                      color: Color.fromARGB(
                                                          255, 11, 57, 94),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: [
                                            for (var supplement in orderItem
                                                .selectedSupplements)
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
                        ],
                      ),
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
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
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
        ),
      ),
    );
  }
}
