import 'package:flutter/material.dart';
import 'package:safe_transfer/data/transfer_data.dart';
import 'package:safe_transfer/widgets/custom_app_bar.dart';
import 'package:safe_transfer/widgets/qr_scan_widget.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Authentication',),
      body: QrScanWidget(onScanCompleted: (data) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AuthenticationResultDialog(transferData: data,);
          },
        );
      },),
    );
  }
}

class AuthenticationResultDialog extends StatelessWidget {
  final TransferData transferData;

  const AuthenticationResultDialog({Key? key, required this.transferData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle amountTextStyle = const TextStyle(
      fontSize: 30,
      color: Color(0xFF00C3B1),
      fontWeight: FontWeight.w500,
    );

    TextStyle amountTextStyle2 = const TextStyle(
      fontSize: 25,
      color: Color(0xFF00C3B1),
      fontWeight: FontWeight.w500,
    );

    TextStyle labelTextStyle = const TextStyle(
      fontSize: 15,
      color: Color(0xFF999999),
    );

    TextStyle contentTextStyle = const TextStyle(
      fontSize: 17,
      color: Color(0xFF00C3B1),
      fontWeight: FontWeight.w500,
    );

    return Dialog(
      insetPadding: EdgeInsets.zero,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 48,
              child: Center(
                child: Text(
                  "Scanned Information",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              height: 2,
              color: const Color(0xFFF2F2F2),
            ),
            Container(
              // height: 410,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Row(
                    children: [
                      Text(
                        '£',
                        style: amountTextStyle2,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        transferData.amount,
                        style: amountTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Amount',
                    style: labelTextStyle,
                  ),

                  // Name, Sour Code
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transferData.name,
                              style: contentTextStyle,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Name',
                              style: labelTextStyle,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transferData.sortCode,
                              style: contentTextStyle,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sort Code',
                              style: labelTextStyle,
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),

                  // Account Number
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transferData.accountNumber,
                        style: contentTextStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Account Number',
                        style: labelTextStyle,
                      ),
                    ],
                  ),

                  // ID
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transferData.id,
                        style: contentTextStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID',
                        style: labelTextStyle,
                      ),
                    ],
                  ),

                  // Button
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        child: _buildIconButton(
                          buttonColor: const Color(0xFFFF5555),
                          iconPath: 'assets/images/cancel.png',
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      InkWell(
                        onTap: () {
                          // 重新扫描
                        },
                        child: _buildIconButton(
                          buttonColor: Colors.black,
                          iconPath: 'assets/images/refresh.png',
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      InkWell(
                        onTap: () {
                          // 向服务器提交认证通过
                        },
                        child: _buildIconButton(
                          buttonColor: const Color(0xFF00C3B1),
                          iconPath: 'assets/images/confirm.png',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required Color buttonColor, required String iconPath}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: buttonColor,
      ),
      child: Center(
        child: Image.asset(
          iconPath,
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}

