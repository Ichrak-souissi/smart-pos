// ignore_for_file: file_names

import 'package:flutter/material.dart';

class PinCodeField extends StatelessWidget {
  final String pin;
  final int pinCodeFieldIndex;
  final PinThemeData theme;
  final Function(String) onChanged;

  const PinCodeField({
    required Key key,
    required this.pin,
    required this.pinCodeFieldIndex,
    required this.onChanged,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      },
      child: Container(
        width: theme.size,
        height: theme.size,
        margin: EdgeInsets.symmetric(horizontal: theme.margin),
        decoration: BoxDecoration(
          color: Colors.green.shade300,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(theme.size / 2),
        ),
        child: Center(
          child: Text(
            pin.length > pinCodeFieldIndex ? pin[pinCodeFieldIndex] : '',
            style: TextStyle(
              fontSize: theme.fontSize,
              color: theme.textColor,
              fontWeight: theme.fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}

class PinThemeData {
  final double size;
  final double margin;
  final Color color;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  PinThemeData({
    this.size = 50.0,
    this.margin = 10.0,
    this.color = Colors.transparent,
    this.textColor = Colors.white,
    this.fontSize = 20.0,
    this.fontWeight = FontWeight.bold,
  });
}