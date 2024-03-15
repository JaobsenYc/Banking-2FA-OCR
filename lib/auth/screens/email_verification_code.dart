import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/auth/cubit/auth_cubit.dart';
import 'package:safe_transfer/auth/device_type/device_type_page.dart';
import 'package:safe_transfer/auth/screens/auth_scaffold.dart';
import 'package:safe_transfer/utils/functions.dart';
import 'package:safe_transfer/utils/validator_service.dart';
import 'package:safe_transfer/widgets/custom_text_input.dart';

class EmailVerification extends StatelessWidget {
  const EmailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    FirebaseAuth.instance.signOut();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: AuthScaffold(
        onAuthSuccess: () {
          authCubit.checkFirstTimeLogin();
        },
        onAuthUserLogin: (bool? isPrimaryDevice) {
          pushReplacement(
            context,
            DeviceTypePage(isPrimaryDevice: isPrimaryDevice),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              const Text(
                '2 Step Verification',
                style: TextStyle(fontSize: 40.0, color: Colors.black),
              ),
              const SizedBox(height: 25.0),
              const Text(
                'We have sent a verification code to your email. Please enter the code below.',
                style: TextStyle(fontSize: 15.0, color: Color(0xff999999)),
              ),
              const SizedBox(height: 25.0),
              CustomTextInput(
                hintText: 'Verification Code',
                controller: TextEditingController(),
                validator: ValidatorService.validateNumber,
              ),
              const SizedBox(height: 25.0),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
