import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/table/models/table.dart';

class CircularTable extends StatelessWidget {
  final int capacity;
  final String tableName;
  final Color borderColor;
  final bool isCircular;

  CircularTable({
    required this.capacity,
    required this.tableName,
    required this.borderColor,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    String tableImage = 'assets/images/table.svg';

    if (capacity == 4) {
      tableImage = 'assets/images/table.svg';
    } else if (capacity == 5) {
      tableImage = 'assets/images/table.svg';
    } else if (capacity >= 8) {
      tableImage = 'assets/images/table.png';
    } else {
      tableImage = 'assets/images/table.svg';
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
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
