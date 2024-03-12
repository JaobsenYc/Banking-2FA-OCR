import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_transfer/quick_service.dart';

class AccountCard extends StatelessWidget {
  final bool showQuickServices;
  const AccountCard({super.key, required this.showQuickServices});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.data();
          return Column(
            children: [
              Container(
                height: 142.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF00E4CE), Color(0xFF00D1FF)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x6600FFE6),
                      blurRadius: 20.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                // 卡片内容
                child: Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/bg_card_visa.png',
                          width: 220.0,
                          height: 72.0,
                        ),
                      ),
                      Positioned(
                        left: 24.0,
                        top: 24.0,
                        right: 24.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Balance',
                              style: TextStyle(
                                  fontSize: 17.0, color: Colors.white),
                            ),
                            Row(
                              children: [
                                const Text(
                                  '£',
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  "${data?['balance']}",
                                  style: const TextStyle(
                                      fontSize: 36.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '**** **** ${data?['accountNumber'].toString().substring(6)}',
                                  style: const TextStyle(
                                      fontSize: 17.0, color: Colors.white),
                                ),
                                Text(
                                  // format the MM/dd from Timestamp to String
                                  DateFormat('MM/yy').format(
                                      (data?['expiryDate'] as Timestamp)
                                          .toDate()),
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              if (showQuickServices)
                QuickService(
                  balance: data?['balance'].toDouble(),
                ),
            ],
          );
        });
  }
}
