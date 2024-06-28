import 'package:flutter/material.dart';

class NumberButton extends StatelessWidget {
  final int number;
  final VoidCallback onPressed;

  const NumberButton({
    required this.number,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 60,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            shape: CircleBorder(),
            elevation: 5,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
