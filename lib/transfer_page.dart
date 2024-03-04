import 'package:flutter/material.dart';
import 'package:safe_transfer/transfer_order_page.dart';
import 'package:safe_transfer/widgets/account_card.dart';
import 'package:safe_transfer/widgets/custom_app_bar.dart';
import 'package:safe_transfer/widgets/custom_button.dart';
import 'package:safe_transfer/widgets/custom_text_input.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Transfer',
      ),
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: Stack(
          children: [
            Column(
              children: [
                const Expanded(child: SizedBox()),
                Image.asset(
                  'assets/images/bg_transfer.png',
                  width: double.infinity,
                  height: 200,
                ),
              ],
            ),
            ListView(
              children: [
                const SizedBox(height: 20),
                // 卡片缩进16
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: AccountCard(),
                ),
                // 输入部分缩进32
                Padding(
                  padding: const EdgeInsets.only(left: 32, right: 32),
                  child: Column(
                    children: [
                      // 输入框
                      const SizedBox(height: 20),
                      const CustomTextInput(hintText: 'Payee Full Name'),
                      const SizedBox(height: 8),
                      const CustomTextInput(hintText: 'Sort Code'),
                      const SizedBox(height: 8),
                      const CustomTextInput(hintText: 'Account Number'),
                      const SizedBox(height: 8),
                      const CustomTextInput(hintText: '£ Amount'),
                      const SizedBox(height: 12),
                      // 按钮
                      CustomButton(
                        text: 'Send Transfer',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TransferOrderPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
