import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    String tableImage = 'assets/images/table6.svg';

    if (capacity == 4) {
      tableImage = 'assets/images/table6.svg';
    } else if (capacity == 5) {
      tableImage = 'assets/images/table6.svg';
    } else if (capacity >= 8) {
      tableImage = 'assets/images/table6.png';
    } else {
      tableImage = 'assets/images/table6.svg';
    }

    return Container(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          // Image de la table
          Center(
            child: SvgPicture.asset(
              tableImage,
              width: 120,
              height: 120,
              color: borderColor, // Ajuster la couleur si nécessaire
            ),
          ),
          // Texte pour l'ID de la table
          Positioned.fill(
            child: Center(
              child: Text(
                tableName,
                style: TextStyle(
                    color: Colors.black, // Couleur du texte
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
