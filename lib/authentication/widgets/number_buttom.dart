import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NumberButton extends StatelessWidget {
  final int number;
  final Function onPressed;

  const NumberButton({super.key, required this.number, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => onPressed(),
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(
            number.toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
