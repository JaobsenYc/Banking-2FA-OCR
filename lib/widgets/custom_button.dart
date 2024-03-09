import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final double? width;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    this.height = 52.0,
    this.borderRadius = 12.0,
    this.backgroundColor = const Color(0xFF04C6B3),
    this.textColor = Colors.white,
    required this.text,
    this.width,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(maxWidth: width ?? double.infinity),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17.0,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
