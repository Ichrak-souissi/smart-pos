import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class CategoryStatisticCircle extends StatelessWidget {
  final RxDouble foodStatValue;
  final RxDouble drinkStatValue;
  final RxDouble otherStatValue;

  const CategoryStatisticCircle({
    Key? key,
    required this.foodStatValue,
    required this.drinkStatValue,
    required this.otherStatValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalValue =
        foodStatValue.value + drinkStatValue.value + otherStatValue.value;

    double foodPercentage =
        totalValue > 0 ? foodStatValue.value / totalValue : 0;
    double drinkPercentage =
        totalValue > 0 ? drinkStatValue.value / totalValue : 0;
    double otherPercentage =
        totalValue > 0 ? otherStatValue.value / totalValue : 0;

    return SizedBox(
      width: 55,
      height: 55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularSegment(
            percentage: foodPercentage,
            color: Color.fromARGB(255, 232, 71, 71),
          ),
          CircularSegment(
            percentage: drinkPercentage,
            color: Color.fromARGB(255, 2, 35, 62),
            startAngle: foodPercentage,
          ),
          CircularSegment(
            percentage: otherPercentage,
            color: Color.fromARGB(255, 39, 200, 82),
            startAngle: foodPercentage + drinkPercentage,
          ),
        ],
      ),
    );
  }
}

class CircularSegment extends StatelessWidget {
  final double percentage;
  final Color color;
  final double startAngle;

  const CircularSegment({
    Key? key,
    required this.percentage,
    required this.color,
    this.startAngle = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 2 * 3.141592653589793 * startAngle,
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          value: percentage,
          strokeWidth: 8,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
