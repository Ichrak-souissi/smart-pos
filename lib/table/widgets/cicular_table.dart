import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CircularTable extends StatelessWidget {
  final int capacity;
  final String tableName;
  final Color borderColor;
  final bool isCircular;

  const CircularTable({
    super.key,
    required this.capacity,
    required this.tableName,
    required this.borderColor,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    String tableImage = 'assets/images/table6.svg';

    if (capacity == 2) {
      tableImage = 'assets/images/table22.svg';
    } else if (capacity == 4) {
      tableImage = 'assets/images/table4.svg';
    } else {
      tableImage = 'assets/images/table6.svg';
    }

    return Container(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Center(
            child: SvgPicture.asset(
              tableImage,
              width: 150,
              height: 150,
              color: borderColor,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                tableName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
