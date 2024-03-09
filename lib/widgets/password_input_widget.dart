import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const PasswordInput({super.key, required this.controller, this.validator});

  @override
  PasswordInputState createState() => PasswordInputState();
}

class PasswordInputState extends State<PasswordInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // input shadow
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5), // changes position of shadow
          ),
        ],
      ),
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(fontSize: 15.0),
        decoration: InputDecoration(
          hintText: 'Enter your password…',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          hintStyle: const TextStyle(color: Color(0xFF999999)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white,
          filled: true,
          // visibility icon
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            color: const Color(0xFFCCCCCC),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}
