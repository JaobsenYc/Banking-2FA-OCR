import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_transfer/auth/screens/login_page.dart';
import 'package:safe_transfer/auth/screens/register_page.dart';
import 'package:safe_transfer/features/local_auth/presentation/pages/local_auth_page.dart';
import 'package:safe_transfer/home_page.dart';
import 'package:safe_transfer/widgets/primary_device_switch.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/sign-in';
  static const String register = '/sign-up';
  static const String profile = '/profile';
  static const String phoneVerification = '/phone-verification';
  static const String localAuth= '/local-auth';

  static String initialRoute =
      FirebaseAuth.instance.currentUser == null ? login : localAuth;

  static Map<String, Widget Function(BuildContext)> routes = {
    register: (context) {
      return RegisterPage();
    },
    login: (context) {
      return LoginPage();
    },
    home: (context) {
      return const HomePage();
    },
    localAuth: (context) {
      return LocalAuthScreen();
    },
    profile: (context) {
      return ProfileScreen(
        appBar: AppBar(title: const Text('Profile')),
        showDeleteConfirmationDialog: true,
        showMFATile: false,
        auth: FirebaseAuth.instance,
        avatarPlaceholderColor: Colors.blue,
        actions: [
          SignedOutAction(
            (context) {
              Navigator.pushNamedAndRemoveUntil(
                  context, login, (route) => false);
            },
          )
        ],
        children: const [
          PrimaryDeviceSwitch(),
        ],
      );
    },
  };
}
