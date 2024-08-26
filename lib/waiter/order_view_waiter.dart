import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/shared/widgets/appbar_widget.dart';

class OrdersViewWaiter extends StatefulWidget {
  const OrdersViewWaiter({super.key});

  @override
  State<OrdersViewWaiter> createState() => _OrdersViewWaiterState();
}

class _OrdersViewWaiterState extends State<OrdersViewWaiter> {
  int _selectedStatus = 0;
  final RxList<Order> orders = RxList<Order>();
  final RxList<OrderItem> orderItems = RxList<OrderItem>();
  final OrderController orderController = Get.put(OrderController());
  final OrderItemController orderItemController =
      Get.put(OrderItemController());

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      await orderController.fetchAllOrders();
      orders.assignAll(orderController.orders);
      await _loadOrderItems();
    } catch (e) {
      print("Error loading orders: $e");
    }
  }

  Future<void> _loadOrderItems() async {
    try {
      final allItems = <OrderItem>[];
      for (var order in orders) {
        await orderItemController.fetchOrderItemsByOrderId(order.id.toString());
        allItems.addAll(orderItemController.orderItems);
      }
      orderItems.assignAll(allItems);
    } catch (e) {
      print("Error loading order items: $e");
    }
  }

  List<Order> _getFilteredOrders() {
    return orders.where((order) {
      // Filtrer par `_selectedStatus`
      if (_selectedStatus == 0) return true; // "Tout"
      if (order.status != _selectedStatus) return false;
      // Filtrer les commandes non payées
      return !order.isPaid;
    }).toList();
  }

  Widget _buildStatusBox(int index, String label) {
    bool isSelected = _selectedStatus == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.green,
            width: 2.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 255, 245),
      body: SafeArea(
        child: Column(
          children: [
            AppBarWidget(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildStatusBox(0, 'Tout'),
                  SizedBox(
                    width: 10,
                  ),
                  _buildStatusBox(1, 'En cours'),
                  SizedBox(
                    width: 10,
                  ),
                  _buildStatusBox(2, 'Prêtes'),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final filteredOrders = _getFilteredOrders();
                if (filteredOrders.isEmpty || orderItems.isEmpty) {
                  return Center(child: Text('Aucune commande disponible.'));
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final List<OrderItem> itemsForOrder = orderItems
                        .where((orderItem) => orderItem.orderId == order.id)
                        .toList();

                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 12,
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.secondaryHeaderColor,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Table N°${order.tableId}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Commande N°${order.id}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Date: ${order.createdAt.toLocal().toString().substring(0, 16)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                if (order.status == 1) ...[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.timer,
                                          color:
                                              Color.fromARGB(255, 243, 196, 10),
                                          size: 20),
                                      SizedBox(height: 6),
                                      Text(
                                        'En cours',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          color: Colors.green, size: 20),
                                      SizedBox(width: 6),
                                      Text(
                                        'Prêt',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Article',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Quantité',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Prix',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  for (var item in itemsForOrder)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${item.price.toStringAsFixed(2)} dt',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        if (item.selectedSupplements != null &&
                                            item.selectedSupplements!
                                                .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Wrap(
                                                    spacing: 2.0,
                                                    runSpacing: 1.0,
                                                    children: item
                                                        .selectedSupplements!
                                                        .map((supplement) {
                                                      return Text(
                                                        '+ ${supplement['name']} - ${supplement['price']} TND',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.secondaryHeaderColor,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(16.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Total: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${order.total.toStringAsFixed(2)} dt',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.receipt, color: Colors.white),
                                  onPressed: () => _showReceiptDialog(
                                      context, order, itemsForOrder),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDialog(
      BuildContext context, Order order, List<OrderItem> itemsForOrder) {
    final taxRate = 0.05;
    final subtotal = order.total;
    final tax = subtotal * taxRate;
    final totalWithTax = subtotal + tax;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Bienvenue')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Table N°${order.tableId}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Commande N°${order.id}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Date: ${order.createdAt.toLocal().toString().substring(0, 16)}',
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.black38),
              ),
              SizedBox(height: 10),
              Divider(),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Article',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Quantité',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Prix',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              for (var item in itemsForOrder)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(item.name),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('${item.quantity}'),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('${item.price.toStringAsFixed(2)} dt'),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    if (item.selectedSupplements != null &&
                        item.selectedSupplements!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: item.selectedSupplements!.map((supplement) {
                            return Text(
                              '+ ${supplement['name']} - ${supplement['price']} TND',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sous-total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${subtotal.toStringAsFixed(2)} dt'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Taxe (5%):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${tax.toStringAsFixed(2)} dt'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${totalWithTax.toStringAsFixed(2)} dt'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
