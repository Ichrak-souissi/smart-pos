import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pos/order-item/controllers/order-item_controller.dart';
import 'package:pos/category/controllers/category_controller.dart';

class CategoryPieChart extends StatelessWidget {
  final OrderItemController orderItemController;
  final CategoryController categoryController;

  CategoryPieChart({
    Key? key,
    required this.orderItemController,
    required this.categoryController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {};

    categoryController.categoryList.forEach((category) {
      double totalQuantity = orderItemController.mostOrderedItems
          .where((item) => item.categoryId == category.id)
          .fold(0, (sum, item) => sum + item.quantity);

      if (totalQuantity > 0) {
        dataMap[category.name] = totalQuantity;
      }
    });

    if (dataMap.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return PieChart(
      dataMap: dataMap,
      chartType: ChartType.disc,
      chartRadius: MediaQuery.of(context).size.width / 2.7,
      colorList: [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.red,
        Colors.deepPurple,
        Colors.cyanAccent,
        Colors.pink
      ],
      initialAngleInDegree: 0,
      legendOptions: const LegendOptions(
        showLegendsInRow: true,
        legendPosition: LegendPosition.bottom,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: const TextStyle(fontSize: 12),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: false,
        showChartValuesOutside: true,
        decimalPlaces: 0,
      ),
    );
  }
}
