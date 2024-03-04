import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:safe_transfer/firebase_options.dart';
import 'package:safe_transfer/home_page.dart';

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
    final providers = [EmailAuthProvider()];

    return MaterialApp(
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            auth: FirebaseAuth.instance,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/home');
              }),
              AuthStateChangeAction<UserCreated>((context, state) {
                Navigator.pushReplacementNamed(context, '/home');
              }),
            ],
          );
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
            children: const [
            ],
          );
        },
      },
    );
  }
}
