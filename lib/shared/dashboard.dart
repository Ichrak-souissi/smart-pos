import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/category/models/category.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/order-item/models/order-item.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/shared/orderCard.dart';
import 'package:pos/table/controllers/table_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final OrderItemController orderItemController =
      Get.put(OrderItemController());
  final OrderController orderController = Get.put(OrderController());
  final CategoryController categoryController = Get.put(CategoryController());
  final TableController tableController = Get.put(TableController());

  @override
  void initState() {
    super.initState();
    categoryController.getCategoryList();
    orderItemController.findMostOrderedItems();
    orderController.orders;
    orderController.fetchAllOrders();
    tableController.getTables();
    tableController.calculateTableOccupancy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          const SizedBox(width: 80),
          _buildSearchBar(),
          SizedBox(width: 8),
          _buildNotification(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      constraints: BoxConstraints(maxWidth: 130, maxHeight: 100),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
    );
  }

  Widget _buildSearchBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 30),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade700,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child:
                            Icon(Icons.search, color: Colors.white, size: 20),
                      ),
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

  Widget _buildNotification() {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: FaIcon(FontAwesomeIcons.bell, color: Colors.black54, size: 25),
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
                            _buildCard(
                              'Total des commandes',
                              Icons.receipt_long_outlined,
                              orderController.orders.length.toDouble(),
                              cardWidth,
                              '${orderController.orders.length} commandes',
                            ),
                            _buildOccupationCard(
                                'Taux d\'occupation des tables', cardWidth),
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
                              _buildRevenueChart(),
                              'Courbe des revenus',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildCardContainer(
                              Obx(() {
                                if (orderItemController
                                    .mostOrderedItems.isEmpty) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: orderItemController
                                        .mostOrderedItems.length,
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
                              'Top des plats',
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Liste des Commandes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: orderController.orders.length,
                            itemBuilder: (context, index) {
                              return OrderCard(
                                  order: orderController.orders[index]);
                            },
                          ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                        color: Colors.black54),
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
                              color: Colors.black),
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
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      series: <ChartSeries>[
        LineSeries<RevenueData, DateTime>(
          dataSource: _generateRevenueData(),
          xValueMapper: (RevenueData revenue, _) => revenue.date,
          yValueMapper: (RevenueData revenue, _) => revenue.amount,
        ),
      ],
    );
  }

  List<RevenueData> _generateRevenueData() {
    return [
      RevenueData(DateTime(2024, 6, 20), 500),
      RevenueData(DateTime(2024, 6, 21), 1500),
      RevenueData(DateTime(2024, 6, 22), 2000),
      RevenueData(DateTime(2024, 6, 23), 800),
      RevenueData(DateTime(2024, 6, 24), 2400),
      RevenueData(DateTime(2024, 6, 25), 1000),
      RevenueData(DateTime(2024, 6, 26), 700),
    ];
  }

  Widget _buildCardContainer(Widget content, String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 500,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  // Exemple d'utilisation d'Obx pour afficher le taux d'occupation des tables
  Widget _buildOccupationCard(String title, double width) {
    return SizedBox(
      width: width,
      child: Obx(() => Container(
            height: 130,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
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
                              '${tableController.occupiedPercentage.value.toStringAsFixed(2)}%',
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
          )),
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
      leading: CircleAvatar(),
      title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${item.quantity} commandes'),
      trailing: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(10),
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
