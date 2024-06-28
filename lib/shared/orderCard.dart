import 'package:flutter/material.dart';
import 'package:pos/order/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color.fromARGB(234, 255, 255, 255),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commande #${order.id}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Table: ${order.tableId}', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
