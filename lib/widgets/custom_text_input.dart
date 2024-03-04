
import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;

  const CustomTextInput({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49.0, // 总高度
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0x0D000000),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          style: const TextStyle(fontSize: 15.0),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
