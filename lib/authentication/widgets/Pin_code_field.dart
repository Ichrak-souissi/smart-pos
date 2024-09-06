import 'package:flutter/material.dart';

class PinCodeField extends StatefulWidget {
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
  _PinCodeFieldState createState() => _PinCodeFieldState();
}

class _PinCodeFieldState extends State<PinCodeField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.pin.length > widget.pinCodeFieldIndex;
    final textColor = widget.theme.textColor;
    final displayText =
        isActive && !_obscureText ? widget.pin[widget.pinCodeFieldIndex] : '*';

    return Container(
      width: widget.theme.size,
      height: widget.theme.size,
      margin: EdgeInsets.symmetric(horizontal: widget.theme.margin),
      child: Center(
        child: Text(
          isActive ? displayText : '_',
          style: TextStyle(
            fontSize: widget.theme.fontSize,
            color: textColor,
            fontWeight: widget.theme.fontWeight,
          ),
        ),
      ),
    );
  }
}

class PinCodeInput extends StatefulWidget {
  final String pin;
  final int numberOfFields;
  final PinThemeData theme;
  final ValueChanged<String> onChanged;

  const PinCodeInput({
    required Key key,
    required this.pin,
    required this.numberOfFields,
    required this.onChanged,
    this.theme = const PinThemeData(),
  }) : super(key: key);

  @override
  _PinCodeInputState createState() => _PinCodeInputState();
}

class _PinCodeInputState extends State<PinCodeInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          widget.numberOfFields,
          (index) => PinCodeField(
            key: UniqueKey(),
            pin: widget.pin,
            pinCodeFieldIndex: index,
            onChanged: widget.onChanged,
            theme: widget.theme,
          ),
        ),
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.theme.textColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ],
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
