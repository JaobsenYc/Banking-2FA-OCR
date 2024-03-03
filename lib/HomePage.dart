import 'package:flutter/material.dart';
import 'package:safe_transfer/AuthenticationPage.dart';
import 'package:safe_transfer/TransferPage.dart';
import 'package:safe_transfer/widgets/AccountCard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        color: const Color(0xFFFAFAFA),
        child: ListView(
          children: const [
            SizedBox(height: 40.0),
            UserHeader(),
            SizedBox(height: 24.0),
            AccountCard(),
            SizedBox(height: 20.0),
            QuickService(),
            SizedBox(height: 20.0),
            Transaction(),
          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction',
          style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666)),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(
                height: 1.0,
                color: Color(0xFFF2F2F2),
              ),
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              // TODO: test data
              List<String> testData = ['income', 'expend', 'expend', 'expend'];
              return TransactionItem(transactionType: testData[index]);
            },
            shrinkWrap: true,
          ),
        ),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String transactionType;

  const TransactionItem({super.key, required this.transactionType});

  @override
  Widget build(BuildContext context) {
    Color textColor = transactionType == 'income'
        ? const Color(0xFFFF5555)
        : const Color(0xFF00C3B1);
    Color iconBackgroundColor = transactionType == 'income'
        ? const Color(0xFFFFEEEE)
        : const Color(0xFFE5F9F7);
    String iconPath = transactionType == 'income'
        ? 'assets/images/income.png'
        : 'assets/images/expend.png';
    var icon = Image.asset(
      iconPath,
      width: 32.0,
      height: 32.0,
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
                '£ 8888.00', // 根据实际情况传入交易金额相关的文字
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: textColor),
              ),
              const Text(
                '2024.01.01', // 根据实际情况传入交易日期相关的文字
                style: TextStyle(fontSize: 14.0, color: Color(0xFF999999)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickService extends StatelessWidget {
  const QuickService({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Service',
          style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666)),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // goto TransferPage
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransferPage()),
                );
              },
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
                      'assets/images/transfer.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'Transfer',
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF04C6B3)),
                    ),
                  ],
                ),
              ),
            ),
            // goto AuthenticationPage
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthenticationPage()),
                );
              },
              child: Container(
                width: 140.0,
                height: 93.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/authentication.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'Authentication',
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF04C6B3)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
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
                    'assets/images/my_bank.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'My Bank',
                    style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF04C6B3)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Container(
            width: 64.0,
            height: 64.0,
            color: Colors.blue, // 替换为实际头像
          ),
        ),
        const SizedBox(width: 8.0),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Welcome, ',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Color(0xFF04C6B3),
                  ),
                ),
              ],
            ),
            Text(
              'Your latest updates are below',
              style: TextStyle(
                fontSize: 15.0,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ],
    );
  }
}