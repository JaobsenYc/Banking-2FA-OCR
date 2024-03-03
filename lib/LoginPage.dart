import 'package:flutter/material.dart';
import 'package:safe_transfer/widgets/CustomButton.dart';
import 'package:safe_transfer/widgets/CustomTextInput.dart';
import 'package:safe_transfer/widgets/PasswordInputWidget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 160.0, left: 32.0, right: 32.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 40.0, color: Colors.black),
            ),
            const Text(
              'Login to access your account',
              style: TextStyle(fontSize: 15.0, color: Color(0xff999999)),
            ),
            const SizedBox(height: 25.0),
            const CustomTextInput(hintText: 'Enter your email…',),
            const SizedBox(height: 8.0),
            const PasswordInput(),
            const SizedBox(height: 10.0),
            CustomButton(
              text: 'Login',
              onPressed: () {
                // Handle login action here, e.g., send data to server.
              },
            ),
            const SizedBox(height: 8.0),
            CustomButton(
              text: 'Create Account',
              backgroundColor: const Color(0x3304C6B3),
              textColor: const Color(0xFF04C6B3),
              onPressed: () {
                // Handle login action here, e.g., send data to server.
              },
            ),
          ],
        ),
      ),
    );
  }
}
