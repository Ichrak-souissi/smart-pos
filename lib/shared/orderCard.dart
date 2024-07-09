import 'package:flutter/material.dart';
import 'package:pos/order/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getStatusText(int status) {
      switch (status) {
        case 1:
          return 'En cours';
        case 2:
          return 'Prête';
        case 3:
          return 'Livrée';
        default:
          return 'Inconnu';
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.id}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Transform.scale(
                  scale:
                      0.7, // Ajustez cette valeur pour changer la taille du Switch
                  child: Switch(
                    value: order.status == 2, // Correspond à "Prête"
                    onChanged: (bool value) {
                      int newStatus =
                          value ? 2 : 1; // Si true, "Prête", sinon "En cours"
                      // Mettre à jour l'état de la commande ici
                      order.status = newStatus;
                      // Si vous utilisez GetX, vous pouvez mettre à jour l'état avec une méthode du contrôleur
                      // orderController.updateOrderStatus(order.id, newStatus);
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ),
              ],
            ),
            Text(
              'Table: ${order.tableId}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Total: ${order.total.toStringAsFixed(2)} dt',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'État: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 14,
                    color: order.status == 2 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
