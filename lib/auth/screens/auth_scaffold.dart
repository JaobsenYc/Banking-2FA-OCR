import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/auth/cubit/auth_cubit.dart';


class AuthScaffold extends StatelessWidget {
  final Widget? child;
  const AuthScaffold({super.key, this.child});

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
      child: child,
    );
  }
}
