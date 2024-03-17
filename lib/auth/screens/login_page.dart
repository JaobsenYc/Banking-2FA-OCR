import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/auth/device_type/device_type_page.dart';
import 'package:safe_transfer/auth/screens/auth_scaffold.dart';
import 'package:safe_transfer/auth/cubit/auth_cubit.dart';
import 'package:safe_transfer/auth/screens/pin_put_dialog.dart';
import 'package:safe_transfer/utils/functions.dart';
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
    final authCubit = context.read<AuthCubit>();
    return AuthScaffold(
      onAuthSuccess: () async {
        FirebaseAuth.instance.signOut();
        final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber!,
          verificationCompleted: (PhoneAuthCredential credential) async {},
          verificationFailed: (FirebaseAuthException e) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone number verification failed'),
              ),
            );
          },
          codeSent: (String verificationId, int? resendToken) async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Code sent to phone number $phoneNumber'),
              ),
            );
            await showDialog(
              context: context,
              builder: (context) {
                return CodeConfirmDialog(
                  phoneNumber: phoneNumber,
                  onDoneEditing: (res) async {
                    try {
                      final credential = PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: res,
                      );
                      await FirebaseAuth.instance
                          .signInWithCredential(credential);
                      authCubit.checkFirstTimeLogin(
                        FirebaseAuth.instance.currentUser?.uid,
                        credential,
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      FirebaseAuth.instance.signOut();
                    } on FirebaseAuthException catch (e) {
                      // ignore: use_build_context_synchronously
                      AwesomeDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.bottomSlide,
                        title: 'Error',
                        desc: e.message!,
                        btnCancelOnPress: () {},
                        btnCancelText: 'Close',
                      ).show();
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      AwesomeDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.bottomSlide,
                        title: 'Error',
                        desc: e.toString(),
                        btnCancelOnPress: () {},
                        btnCancelText: 'Close',
                      ).show();
                    }
                  },
                );
              },
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
        return;
      },
      onAuthUserLogin:
          (bool? isPrimaryDevice, PhoneAuthCredential phoneAuthCredential) {
        pushReplacement(
          context,
          DeviceTypePage(
            isPrimaryDevice: isPrimaryDevice,
            phoneAuthCredential: phoneAuthCredential,
          ),
        );
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_login.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.only(top: 160.0, left: 32.0, right: 32.0),
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
                  const SizedBox(height: 15.0),
                  PasswordInput(
                    controller: passwordController,
                    validator: ValidatorService.passwordValidator,
                  ),
                  const SizedBox(height: 30.0),
                  CustomButton(
                    text: 'Login',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthCubit>().signInWithEmailAndPassword(
                            emailController.text, passwordController.text);
                      }
                    },
                  ),
                  const SizedBox(height: 15.0),
                  CustomButton(
                    text: 'Create Account',
                    backgroundColor: const Color(0x3304C6B3),
                    textColor: const Color(0xFF04C6B3),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/sign-up');
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
