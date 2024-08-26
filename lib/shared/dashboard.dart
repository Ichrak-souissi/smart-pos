import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/category/models/category.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/shared/widgets/appbar_widget.dart';
import 'package:pos/table/controllers/table_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'widgets/category_pieChart.dart';

class DashboardPage extends StatelessWidget {
  final OrderItemController orderItemController =
      Get.put(OrderItemController());
  final OrderController orderController = Get.put(OrderController());
  final CategoryController categoryController = Get.put(CategoryController());
  final TableController tableController = Get.put(TableController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 255, 245),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarWidget(),
            SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double cardWidth = (constraints.maxWidth - 32) / 3;
                        return Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: [
                            Obx(() {
                              double totalRevenue = orderController.orders.fold(
                                0.0,
                                (sum, order) => sum + order.total,
                              );
                              return _buildCard(
                                'Total des revenus',
                                Icons.monetization_on_rounded,
                                totalRevenue / 1000,
                                cardWidth,
                                '${totalRevenue.toStringAsFixed(2)} dt',
                              );
                            }),
                            Obx(() {
                              return _buildCard(
                                'Total des commandes',
                                Icons.receipt_long_outlined,
                                orderController.orders.length.toDouble(),
                                cardWidth,
                                '${orderController.orders.length} commandes',
                              );
                            }),
                            _buildOccupationCard(
                              'Taux d\'occupation des tables',
                              cardWidth,
                            ),
                          ],
                        );
                      },
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildCardContainer(
                              CategoryPieChart(
                                orderItemController: orderItemController,
                                categoryController: categoryController,
                              ),
                              'Catégories commandées',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildCardContainer(
                              _buildRevenueChart(),
                              'Revenus par mois',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Top des plats',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: Obx(() {
                            if (orderItemController.mostOrderedItems.isEmpty) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return ListView.builder(
                                itemCount:
                                    orderItemController.mostOrderedItems.length,
                                itemBuilder: (context, index) {
                                  OrderItem item = orderItemController
                                      .mostOrderedItems[index];
                                  Category? category = categoryController
                                      .categoryList
                                      .firstWhereOrNull((category) =>
                                          category.id == item.categoryId);
                                  return OrderItemTile(
                                      item: item, category: category);
                                },
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, double statValue, double width,
      String indicatorText) {
    return SizedBox(
      width: width,
      child: Container(
        height: 130,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statValue.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          indicatorText,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    List<RevenueData> revenueData = _generateRevenueData();

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        majorGridLines: MajorGridLines(width: 1),
      ),
      series: <CartesianSeries>[
        ColumnSeries<RevenueData, DateTime>(
          dataSource: revenueData,
          xValueMapper: (RevenueData revenue, _) => revenue.date,
          yValueMapper: (RevenueData revenue, _) => revenue.amount,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
          ),
        ),
      ],
    );
  }

  List<RevenueData> _generateRevenueData() {
    List<Order> orders = orderController.orders;
    Map<DateTime, double> dailyRevenueMap = {};

    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      dailyRevenueMap[DateTime(now.year, now.month, day)] = 0.0;
    }

    orders.forEach((order) {
      DateTime createdAt = DateTime(
          order.createdAt.year, order.createdAt.month, order.createdAt.day);

      dailyRevenueMap[createdAt] = dailyRevenueMap[createdAt] =
          (dailyRevenueMap[createdAt] ?? 0.0) +
              double.parse(order.total.toStringAsFixed(2));
    });

    List<RevenueData> revenueData = dailyRevenueMap.entries
        .where((entry) => entry.value != 0.0)
        .map((entry) => RevenueData(entry.key, entry.value))
        .toList();

    revenueData.sort((a, b) => a.date.compareTo(b.date));

    return revenueData;
  }

  Widget _buildCardContainer(Widget content, String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: 500,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              SizedBox(height: 10),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccupationCard(String title, double width) {
    return SizedBox(
      width: width,
      child: GetBuilder<TableController>(
        init: TableController(),
        builder: (tableController) {
          double occupiedPercentage = tableController.occupiedPercentage.value;

          return Container(
            height: 130,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.table_chart, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${occupiedPercentage.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Occupé',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrderItemTile extends StatelessWidget {
  final OrderItem item;
  final Category? category;

  const OrderItemTile({
    required this.item,
    required this.category,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(item.imageUrl),
      ),
      title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${item.quantity} commandes'),
      trailing: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${category?.name ?? 'Unknown Category'}',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class RevenueData {
  final DateTime date;
  final double amount;

  RevenueData(this.date, this.amount);
}
