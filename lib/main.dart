import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/firebase_options.dart';
import 'package:safe_transfer/home_page.dart';
import 'package:safe_transfer/login/cubit/auth_cubit.dart';
import 'package:safe_transfer/login/login_page.dart';
import 'package:safe_transfer/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        initialRoute:
            FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
        routes: {
          '/sign-up': (context) {
            return  RegisterPage();
          },
          '/sign-in': (context) {
            return  LoginPage();
          },
          '/home': (context) {
            return const HomePage();
          },
          '/profile': (context) {
            return ProfileScreen(
              appBar: AppBar(title: const Text('Profile')),
              providers: [EmailAuthProvider()],
              showDeleteConfirmationDialog: true,
              showMFATile: true,
              auth: FirebaseAuth.instance,
              avatarPlaceholderColor: Colors.blue,
              actions: [
                SignedOutAction((context) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/sign-in', (route) => false);
                })
              ],
              children: const [],
            );
          },
        },
      ),
    );
  }
}
