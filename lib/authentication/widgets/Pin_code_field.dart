import 'package:flutter/material.dart';

class PinCodeField extends StatelessWidget {
  final String pin;
  final int pinCodeFieldIndex;
  final PinThemeData theme;
  final ValueChanged<String> onChanged;

  const PinCodeField({
    required Key key,
    required this.pin,
    required this.pinCodeFieldIndex,
    required this.onChanged,
    this.theme = const PinThemeData(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = pin.length > pinCodeFieldIndex;
    final textColor = theme.textColor;

    return Container(
      width: theme.size,
      height: theme.size,
      margin: EdgeInsets.symmetric(horizontal: theme.margin),
      child: Center(
        child: Text(
          isActive ? '*' : '_',
          style: TextStyle(
            fontSize: theme.fontSize,
            color: textColor,
            fontWeight: theme.fontWeight,
          ),
        ),
      ),
    );
  }
}

class PinThemeData {
  final double size;
  final double margin;
  final Color activeFillColor;
  final Color inactiveFillColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color textColor;
  final Color inactiveTextColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showShadow;
  final Color shadowColor;
  final double shadowSpreadRadius;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  const PinThemeData({
    this.size = 50.0,
    this.margin = 5.0,
    this.activeFillColor = Colors.transparent,
    this.inactiveFillColor = Colors.transparent,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0.0,
    this.borderRadius = 0.0,
    this.textColor = Colors.black,
    this.inactiveTextColor = Colors.black,
    this.fontSize = 30.0,
    this.fontWeight = FontWeight.bold,
    this.showShadow = false,
    this.shadowColor = Colors.transparent,
    this.shadowSpreadRadius = 0.0,
    this.shadowBlurRadius = 1.0,
    this.shadowOffset = Offset.zero,
  });
}
