import 'package:flutter/material.dart';
import 'package:pos/app_theme.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.selectedIcon,
    required this.index,
  });

  final VoidCallback onTap;
  final IconData icon;
  final int selectedIcon;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55.0,
        height: 55.0,
        decoration: BoxDecoration(
          color: selectedIcon == index
              ? Colors.white
              : AppTheme.lightTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            size: 30,
            icon,
            color: selectedIcon == index
                ? AppTheme.lightTheme.primaryColor
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
