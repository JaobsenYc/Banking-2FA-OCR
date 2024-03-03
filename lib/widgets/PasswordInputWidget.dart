import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  PasswordInputState createState() => PasswordInputState();
}

class PasswordInputState extends State<PasswordInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0x0D000000),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                obscureText: !_isPasswordVisible,
                style: const TextStyle(fontSize: 15.0),
                decoration: const InputDecoration(
                  hintText: 'Enter your password…',
                  hintStyle: TextStyle(color: Color(0xFF999999)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
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
        ],
      ),
    );
  }
}
