import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:safe_transfer/auth/cubit/auth_cubit.dart';
import 'package:safe_transfer/auth/screens/auth_scaffold.dart';
import 'package:safe_transfer/auth/screens/pin_put_dialog.dart';
import 'package:safe_transfer/auth/screens/verify_phone_number_sceen.dart';
import 'package:safe_transfer/utils/app_routes.dart';
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

  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return AuthScaffold(
      onAuthSuccess: () {
        // show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        // navigate to login page
        Navigator.pushNamed(context, AppRoutes.login);
      },
      child: Form(
        key: formKey,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_login.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 160.0,
                left: 32.0,
                right: 32.0,
              ),
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
                  // phone nnumber input
                  IntlPhoneField(
                    onChanged: (phone) {
                      phoneController.text = phone.completeNumber;
                    },
                    initialCountryCode: 'GB',
                    decoration: const InputDecoration(
                      hintText: 'Enter your phone number…',
                      hintStyle: TextStyle(color: Color(0xff999999)),
                      border: InputBorder.none,
                    ),
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
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: phoneController.text,
                        verificationCompleted:
                            (PhoneAuthCredential credential) async {},
                        verificationFailed: (FirebaseAuthException e) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone number verification failed'),
                            ),
                          );
                        },
                        codeSent:
                            (String verificationId, int? resendToken) async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Code sent to phone number ${phoneController.text}'),
                            ),
                          );
                          final res = await showDialog(
                            context: context,
                            builder: (context) {
                              return CodeConfirmDialog(
                                phoneNumber: phoneController.text,
                              );
                            },
                          );
                          if (res != null) {
                            try {
                              final credential = PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: res,
                              );
                              await FirebaseAuth.instance.signInWithCredential(
                                credential,
                              );
                              cubit.signUpWithEmailAndPassword(
                                emailController.text,
                                phoneController.text,
                                passwordController.text,
                              );
                            } on FirebaseAuthException
                            catch (e) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Error: ${e.message}'),
                                ),
                              );
                            }
                            catch (e) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something went wrong!'),
                                ),
                              );
                            }
                          }
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );
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
