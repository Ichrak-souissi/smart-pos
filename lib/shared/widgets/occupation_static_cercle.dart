import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:pos/app_theme.dart';

class OccupationStatisticCircle extends StatelessWidget {
  final RxDouble occupiedStatValue;
  final RxDouble availableStatValue;

  const OccupationStatisticCircle({
    Key? key,
    required this.occupiedStatValue,
    required this.availableStatValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalValue = occupiedStatValue.value + availableStatValue.value;

    double occupiedPercentage =
        totalValue > 0 ? occupiedStatValue.value / totalValue : 0;
    double availablePercentage =
        totalValue > 0 ? availableStatValue.value / totalValue : 0;

    return SizedBox(
      width: 55,
      height: 55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularSegment(
            percentage: occupiedPercentage,
            color: Color.fromARGB(255, 232, 71, 71),
          ),
          CircularSegment(
            percentage: availablePercentage,
            color: AppTheme.lightTheme.primaryColor,
            startAngle: occupiedPercentage,
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
