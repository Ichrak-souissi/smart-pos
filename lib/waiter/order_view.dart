import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/shared/widgets/appbar_widget.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RxList<Order> orders = RxList<Order>();
  final RxList<OrderItem> orderItems = RxList<OrderItem>();
  final OrderController orderController = Get.put(OrderController());
  final OrderItemController orderItemController =
      Get.put(OrderItemController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  List<Order> _filterOrders(int status) {
    if (status == 0) return orders;
    return orders.where((order) => order.status == status).toList();
  }

  void _updateOrderStatus(Order order, bool isReady) async {
    int newStatus = isReady ? 2 : 1;
    try {
      await orderController.updateOrderStatus(order.id.toString(), newStatus);
    } catch (e) {
      print('Failed to update order status: $e');
    }
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
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Tout'),
                  Tab(text: 'Prêtes'),
                  Tab(text: 'En cours'),
                ],
                labelColor: AppTheme.lightTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.lightTheme.primaryColor,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(0),
                  _buildOrderList(2),
                  _buildOrderList(1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(int status) {
    return Obx(() {
      final filteredOrders = _filterOrders(status);
      if (filteredOrders.isEmpty || orderItems.isEmpty) {
        return Center(child: Text('Aucune commande disponible.'));
      }
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 15.0,
          crossAxisSpacing: 15.0,
          childAspectRatio: 0.8,
        ),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          final List<OrderItem> itemsForOrder =
              orderItems.where((item) => item.orderId == order.id).toList();

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
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.secondaryHeaderColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.0)),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Table N°${order.tableId}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Commande N°${order.id}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
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
                            Transform.scale(
                              scale: 0.9,
                              child: Switch(
                                value: order.status == 2,
                                onChanged: (bool value) {
                                  setState(() {
                                    order.status = value ? 2 : 1;
                                  });
                                  _updateOrderStatus(order, value);
                                },
                                activeColor:
                                    const Color.fromARGB(255, 197, 224, 198),
                                inactiveThumbColor: Colors.red,
                                inactiveTrackColor: Colors.red.withOpacity(0.3),
                                activeTrackColor:
                                    Color.fromARGB(255, 42, 151, 45),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              order.status == 1 ? 'En cours' : 'Prêt',
                              style: TextStyle(
                                fontSize: 12,
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
                                color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Prêt',
                              style: TextStyle(
                                fontSize: 12,
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
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var item in itemsForOrder)
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 12.0),
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity} x ${item.name}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.note.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'Note: ${item.note}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                                if (item.selectedSupplements.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'Suppléments:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: item.selectedSupplements
                                        .map((supplement) => Row(
                                              children: [
                                                SizedBox(width: 4),
                                                Text(
                                                  '- ${supplement['name']}',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.secondaryHeaderColor,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(16.0)),
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
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
