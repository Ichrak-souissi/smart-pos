import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

class TableShape  {
  final double width;
  final double height;
  final double legWidth;
  final double legHeight;

  TableShape({
    required this.width,
    required this.height,
    required this.legWidth,
    required this.legHeight,
  });

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();

    // Draw the table top
    path.moveTo(0, 0);
    path.lineTo(width - legWidth, 0);
    path.lineTo(width - legWidth, height - legHeight);
    path.lineTo(0, height - legHeight);
    path.close();

    // Draw the table legs
    path.moveTo(width - legWidth, 0);
    path.lineTo(width, 0);
    path.lineTo(width, legHeight);
    path.lineTo(width - legWidth, legHeight);
    path.close();

    path.moveTo(0, height - legHeight);
    path.lineTo(legWidth, height - legHeight);
    path.lineTo(legWidth, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();

    // Draw the table top outline
    path.addRect(
      Rect.fromLTWH(0, 0, width - legWidth, height - legHeight),
    );

    // Draw the table legs
    path.moveTo(width - legWidth, 0);
    path.lineTo(width, 0);
    path.lineTo(width, legHeight);
    path.lineTo(width - legWidth, legHeight);
    path.close();

    path.moveTo(0, height - legHeight);
    path.lineTo(legWidth, height - legHeight);
    path.lineTo(legWidth, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;

    canvas.drawPath(getInnerPath(rect), paint);

    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(getOuterPath(rect), strokePaint);
  }
}


class TablePainting extends StatelessWidget {
  final double width;
  final double height;
  final double legWidth;
  final double legHeight;

  TablePainting({
    required this.width,
    required this.height,
    required this.legWidth,
    required this.legHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: TablePainter(
        width: width,
        height: height,
        legWidth: legWidth,
        legHeight: legHeight, numPersons: 5
      ),
    );
  }
}







class TablePainter extends CustomPainter {
  final double width;
  final double height;
  final double legWidth;
  final double legHeight;
  final int numPersons;

  TablePainter({
    required this.width,
    required this.height,
    required this.legWidth,
    required this.legHeight,
    required this.numPersons,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tableShape = TableShape(
      width: width,
      height: height,
      legWidth: legWidth,
      legHeight: legHeight,
    );

    tableShape.paint(canvas, Offset.zero & size);

    // Draw circles for each person sitting at the table
    final radius = min(width, height) * 0.05; // Radius of the circles
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Calculate the positions for up to four persons
    final positions = [
      Offset(legWidth, legHeight), // Top left
      Offset(width - legWidth, legHeight), // Top right
      Offset(legWidth, height - legHeight), // Bottom left
      Offset(width - legWidth, height - legHeight), // Bottom right
    ];

    // Draw circles for the first four persons
    for (int i = 0; i < min(numPersons, positions.length); i++) {
      canvas.drawCircle(positions[i], radius, paint);
    }

    // If there are more persons, calculate their positions in a circle around the table
    if (numPersons > 4) {
      final center = Offset(width / 2, height / 2);
      final angleStep = (2 * math.pi) / (numPersons - 4);
      for (int i = 4; i < numPersons; i++) {
        final angle = i * angleStep;
        final x = center.dx + (width / 2 - legWidth) * math.cos(angle);
        final y = center.dy + (height / 2 - legHeight) * math.sin(angle);
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
