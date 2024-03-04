
import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
 final String? Function(String?)? validator;

  const  CustomTextInput({
    Key? key,
    required this.hintText,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      style: const TextStyle(fontSize: 15.0),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        hintStyle: const TextStyle(color: Color(0xFF999999)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
