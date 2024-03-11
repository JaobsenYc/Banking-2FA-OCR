import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_transfer/data/transfer_data.dart';
import 'package:safe_transfer/quick_service.dart';
import 'package:safe_transfer/transfer_order_page.dart';
import 'package:safe_transfer/widgets/account_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0),
          color: const Color(0xFFFAFAFA),
          child: const Column(
            children: [
              SizedBox(height: 40.0),
              UserHeader(),
              SizedBox(height: 24.0),
              AccountCard(),
              SizedBox(height: 20.0),
              Transaction(),
            ],
          ),
        ),
      ),
    );
  }
}

class Transaction extends StatelessWidget {
  const Transaction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transfers')
              .orderBy('createdAt', descending: true)
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              debugPrint('Error: ${snapshot.error}');
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.money_off_csred_sharp,
                      size: 28.0,
                      color: Color(0xFF999999),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'No transaction yet',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Divider(
                  height: 1.0,
                  color: Color(0xFFF2F2F2),
                ),
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransferOrderPage(
                          model: TransferData(
                            amount: data['amount'].toDouble(),
                            name: data['payeeFullName'],
                            sortCode: data['sortCode'],
                            accountNumber: data['accountNumber'],
                            id: data.id,
                            encryptedData: data['encryptedData'],
                          ),
                        ),
                      ),
                    );
                  },
                  child: TransactionItem(
                    amount: data['amount'],
                    date: Timestamp.fromMillisecondsSinceEpoch(
                      data['createdAt'],
                    ).toDate(),
                    transactionType: data['status'],
                  ),
                );
              },
            );
          },
        ),
        /*               child: FirestoreListView<Map<String, dynamic>>.separated(
          shrinkWrap: true,
          emptyBuilder: (context) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.money_off_csred_sharp,
                  size: 28.0,
                  color: Color(0xFF999999),
                ),
                SizedBox(height: 2.0),
                Text(
                  'No transaction yet',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (context, index) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Divider(
              height: 1.0,
              color: Color(0xFFF2F2F2),
            ),
          ),
          query: FirebaseFirestore.instance
              .collection('transfers')
              .orderBy('createdAt', descending: true)
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              ),
          itemBuilder: (context, data) {
            return InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferOrderPage(
                      model: TransferData(
                        amount: data['amount'].toDouble(),
                        name: data['payeeFullName'],
                        sortCode: data['sortCode'],
                        accountNumber: data['accountNumber'],
                        id: data.id,
                        encryptedData: data['encryptedData'],
                      ),
                    ),
                  ),
                );
              },
              child: TransactionItem(
                amount: data['amount'],
                date: DateTime.parse(data['createdAt']).toLocal(),
                transactionType: data['status'],
              ),
            );
          },
        ), */
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String transactionType;
  final num amount;
  final DateTime date;

  const TransactionItem(
      {super.key,
      required this.transactionType,
      required this.amount,
      required this.date});

  @override
  Widget build(BuildContext context) {
    Color textColor = transactionType == 'initiated'
        ? const Color.fromARGB(255, 220, 77, 29)
        : transactionType == 'income'
            ? const Color(0xFFFF5555)
            : const Color(0xFF00C3B1);
    Color iconBackgroundColor = transactionType == 'initiated'
        ? const Color.fromARGB(255, 255, 240, 230)
        : transactionType == 'income'
            ? const Color(0xFFFFEEEE)
            : const Color(0xFFE5F9F7);

    // icon color
    Color iconColor = transactionType == 'initiated'
        ? const Color.fromARGB(255, 220, 77, 29)
        : transactionType == 'income'
            ? const Color(0xFFFF5555)
            : const Color(0xFF00C3B1);
    String iconPath = transactionType == 'initiated'
        ? 'assets/images/authentication.png'
        : transactionType == 'income'
            ? 'assets/images/income.png'
            : 'assets/images/expend.png';
    var icon = Image.asset(
      iconPath,
      width: 32.0,
      height: 32.0,
      color: iconColor,
    );

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackgroundColor,
            ),
            child: Center(
              child: icon,
            ),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Salary', // 根据实际情况传入交易内容相关的文字
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  transactionType,
                  style:
                      const TextStyle(fontSize: 14.0, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '£ $amount', // 根据实际情况传入交易金额相关的文字
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: textColor),
              ),
              Text(
                '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}', // 根据实际情况传入交易日期相关的文字
                style:
                    const TextStyle(fontSize: 14.0, color: Color(0xFF999999)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/profile');
      },
      child: Row(
        children: [
          const UserAvatar(
            size: 64.0,
            placeholderColor: Colors.blue,
          ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                    ),
                  ),
                  if (FirebaseAuth.instance.currentUser?.displayName != null)
                    Row(
                      children: [
                        const Text(
                          ', ',
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser!.displayName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                            color: Color(0xFF04C6B3),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Text(
                'Your latest updates are below',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
