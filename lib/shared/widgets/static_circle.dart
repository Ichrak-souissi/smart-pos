import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:pos/app_theme.dart';

class StatisticCircle extends StatelessWidget {
  final RxDouble statValue;
  final IconData? icon;

  const StatisticCircle({Key? key, required this.statValue, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: statValue.value,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor:
                AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor),
          ),
        ),
        Icon(
          icon,
          size: 35,
          color: Color.fromARGB(255, 240, 76, 54),
        ),
      ],
    );
  }
}
