import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/auth/cubit/auth_cubit.dart';
import 'package:safe_transfer/features/local_auth/presentation/cubit/local_auth_cubit.dart';
import 'package:safe_transfer/home_page.dart';
import 'package:safe_transfer/utils/functions.dart';
import 'package:safe_transfer/utils/validator_service.dart';
import 'package:safe_transfer/widgets/custom_button.dart';
import 'package:safe_transfer/widgets/password_input_widget.dart';

class LocalAuthScreen extends StatelessWidget {
  LocalAuthScreen({super.key});

  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LocalAuthCubit()..checkBiometrics(),
        ),
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
      ],
      child: Scaffold(
        body: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_login.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  pushReplacement(context, const HomePage());
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                    ),
                  );
                }
              },
              child: BlocConsumer<LocalAuthCubit, LocalAuthState>(
                listener: (context, state) {
                  if (state is LocalAuthDone) {
                    if (state.res) {
                      pushReplacement(context, const HomePage());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please try with your password to authenticate"),
                        ),
                      );
                    }
                  }
                  if (state is LocalAuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Please try with your password to authenticate"),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final authCubit = context.read<AuthCubit>();
                  final loacalAuthCubit = context.read<LocalAuthCubit>();
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          top: 160.0, left: 32.0, right: 32.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                  fontSize: 40.0, color: Colors.black),
                            ),
                            const Text(
                              'Acces to your account',
                              style: TextStyle(
                                  fontSize: 15.0, color: Color(0xff999999)),
                            ),
                            if (state is! LocalAuthLoading) ...[
                              const SizedBox(height: 25.0),
                              PasswordInput(
                                controller: _passwordController,
                                validator: ValidatorService.passwordValidator,
                              ),
                              const SizedBox(height: 30.0),
                              CustomButton(
                                text: 'Authenticate',
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    authCubit.signInWithEmailAndPassword(
                                      FirebaseAuth.instance.currentUser!.email!,
                                      _passwordController.text,
                                    );
                                  }
                                },
                              ),
                            ],
                            const SizedBox(height: 30.0),
                            // button to authenticate with biometrics
                            Center(
                              child: InkWell(
                                onTap: () {
                                  loacalAuthCubit.checkBiometrics();
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration:  BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFF04C6B3), width: 2.0
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                              child: Center(
                                                  child: Icon(
                                            Icons.fingerprint,
                                            size: 30,
                                          ))),

                                          // face id icon
                                          Expanded(
                                              child: Center(
                                                  child: Icon(
                                            Icons.face,
                                            size: 30,
                                          ))),
                                        ],
                                      ),
                                    ),
                                    // cirular progress indicator
                                    if (state is LocalAuthLoading)
                                      const Center(
                                        child: SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF04C6B3),
                                            strokeWidth: 2.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
