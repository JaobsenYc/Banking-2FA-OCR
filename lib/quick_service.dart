import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_transfer/authentication_page.dart';
import 'package:safe_transfer/transfer/transfer_page.dart';
import 'package:safe_transfer/main.dart'; // Assuming 'deviceInfo' is available here

class QuickService extends StatefulWidget {
  const QuickService({super.key});

  @override
  State<QuickService> createState() => _QuickServiceState();
}

class _QuickServiceState extends State<QuickService> {
  bool _isPrimaryDevice = false;

  // StreamSubscription
  StreamSubscription<DocumentSnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToStatusChanges();
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Cancel the stream subscription when disposing
    super.dispose();
  }

  Future<void> _listenToStatusChanges() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      _subscription = docRef.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          setState(() {
            _isPrimaryDevice = data['primaryDeviceId'] == deviceInfo.deviceId;
          });
        }
      });
    } on FirebaseException catch (e) {
      // Handle errors
      debugPrint('Error listening to device status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Quick Service',
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666)),
                  ),
                  const Spacer(),
                  if (_isPrimaryDevice) ...[
                    const Text(
                      'Primary Device',
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF04C6B3)),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF04C6B3),
                      size: 16.0,
                    ),
                  ],
                  if (!_isPrimaryDevice) ...[
                    const Text(
                      'Authenticator Device',
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666)),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(
                      Icons.error,
                      color: Color(0xFF666666),
                      size: 16.0,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  if (_isPrimaryDevice) ...[
                    // goto TransferPage
                    quickServiceItem(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransferPage())),
                        iconPath: 'assets/images/transfer.png',
                        title: 'Transfer'),
                  ] else ...[
                    // goto AuthenticationPage
                    quickServiceItem(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AuthenticationPage())),
                        iconPath: 'assets/images/authentication.png',
                        title: 'Authentication'),
                  ],
                  const SizedBox(width: 16.0),
                  quickServiceItem(
                      onTap: () {
                        // Handle "My Bank" action
                      },
                      iconPath: 'assets/images/my_bank.png',
                      title: 'My Bank'),
                ],
              ),
            ],
          );
  }

  Widget quickServiceItem({
    required VoidCallback onTap,
    required String iconPath,
    required String title,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 88.0,
        height: 93.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF04C6B3)),
            ),
          ],
        ),
      ),
    );
  }
}
