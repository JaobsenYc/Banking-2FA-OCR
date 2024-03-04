import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/auth/cubit/auth_cubit.dart';
import 'package:safe_transfer/auth/screens/auth_scaffold.dart';
import 'package:safe_transfer/utils/validator_service.dart';
import 'package:safe_transfer/widgets/custom_button.dart';
import 'package:safe_transfer/widgets/custom_text_input.dart';
import 'package:safe_transfer/widgets/password_input_widget.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: formKey,
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.only(top: 160.0, left: 32.0, right: 32.0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_login.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 40.0, color: Colors.black),
                  ),
                  const Text(
                    'Create your account below',
                    style: TextStyle(fontSize: 15.0, color: Color(0xff999999)),
                  ),
                  const SizedBox(height: 25.0),
                  CustomTextInput(
                    hintText: 'Enter your email…',
                    controller: emailController,
                    validator: ValidatorService.emailValidator,
                  ),
                  const SizedBox(height: 20),
                  PasswordInput(
                    controller: passwordController,
                    validator: ValidatorService.passwordValidator,
                  ),
                  const SizedBox(height: 20.0),
                  PasswordInput(
                    controller: confirmPasswordController,
                    validator: (value) {
                      return ValidatorService.confirmPasswordValidator(
                          value, passwordController.text);
                    },
                  ),
                  const SizedBox(height: 30.0),
                  CustomButton(
                    text: 'Create Account',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthCubit>().signUpWithEmailAndPassword(
                              emailController.text,
                              passwordController.text,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
