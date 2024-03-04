import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/login/cubit/auth_cubit.dart';
import 'package:safe_transfer/utils/validator_service.dart';
import 'package:safe_transfer/widgets/custom_button.dart';
import 'package:safe_transfer/widgets/custom_text_input.dart';
import 'package:safe_transfer/widgets/password_input_widget.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthError) {
          Navigator.pop(context);
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Error',
            desc: state.message,
            btnCancelOnPress: () {},
            btnCancelText: 'Close',
          ).show();
        } else if (state is AuthLoading) {
          showDialog(
              context: context,
              builder: (_) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
        }
      },
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(top: 160.0, left: 32.0, right: 32.0),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_login.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: formKey,
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
                CustomTextInput(
                  hintText: 'Enter your email…',
                  controller: emailController,
                  validator: ValidatorService.emailValidator,
                ),
                const SizedBox(height: 8.0),
                PasswordInput(
                  controller: passwordController,
                  validator: ValidatorService.passwordValidator,
                ),
                const SizedBox(height: 10.0),
                CustomButton(
                  text: 'Login',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<AuthCubit>().signInWithEmailAndPassword(
                            emailController.text,
                            passwordController.text,
                          );
                    }
                  },
                ),
                const SizedBox(height: 8.0),
                CustomButton(
                  text: 'Create Account',
                  backgroundColor: const Color(0x3304C6B3),
                  textColor: const Color(0xFF04C6B3),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
