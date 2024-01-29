
import 'dart:ui';

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
    required this.onChanged, required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ClipRect(
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(
        width: theme.size,
        height: theme.size,
        margin: EdgeInsets.symmetric(horizontal: theme.margin),
        decoration: BoxDecoration(
          color: theme.color,
          borderRadius: BorderRadius.circular(theme.borderRadius),
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
        )
    );
  }
}

class PinThemeData {
  final double size;
  final double margin;
  final double borderRadius;
  final Color color =  Colors.black38;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  PinThemeData({
    this.size = 50.0,
    this.margin = 10.0,
    this.borderRadius = 10.0,
    this.textColor = Colors.white,
    this.fontSize = 20.0,
    this.fontWeight = FontWeight.bold,
  });
}