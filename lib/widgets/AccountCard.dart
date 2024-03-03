import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    style: TextStyle(fontSize: 17.0, color: Colors.white),
                  ),
                  const Row(
                    children: [
                      Text(
                        '£',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        '8,848',
                        style: TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '**** 0123',
                        style: TextStyle(fontSize: 17.0, color: Colors.white),
                      ),
                      Text(
                        DateFormat('MM/dd').format(DateTime.now()),
                        style: const TextStyle(
                            fontSize: 17.0, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}