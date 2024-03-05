import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:safe_transfer/widgets/custom_app_bar.dart';

class TransferOrderPage extends StatelessWidget {
  final String id;
  final String payeeFullName;
  final int sortCode;
  final String accountNumber;
  final String amount;

  const TransferOrderPage(
      {super.key,
      required this.id,
      required this.payeeFullName,
      required this.sortCode,
      required this.accountNumber,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Transfer'),
      body: Container(
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: getContent(),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
    );
  }

  Widget getContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      children: [
        // 二维码
        const SizedBox(height: 40.0),
        Center(
          child: SizedBox(
            width: 250,
            child: PrettyQrView.data(
              data: id,
              decoration: const PrettyQrDecoration(
                image: PrettyQrDecorationImage(
                  scale: .12,
                  // TODO : Add logo of the app
                  image: AssetImage(
                    'assets/images/transfer.png',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        const Center(
          child: Text(
            'Scan the code using APP',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 17,
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        Column(
          children: [
            buildListTile('Name:', payeeFullName),
            Container(height: 1, color: const Color(0xFFF2F2F2)),
            buildListTile('Sort code:', '$sortCode'),
            Container(height: 1, color: const Color(0xFFF2F2F2)),
            buildListTile('Account number:', accountNumber),
            Container(height: 1, color: const Color(0xFFF2F2F2)),
            buildListTile2(
                'Amount:',
                Text(
                  '￡$amount',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )),
          ],
        ),
        const SizedBox(height: 10.0),
        getIDCard('ID: $id'),
      ],
    );
  }

  Widget buildListTile(String leftText, String rightText) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 15,
            ),
          ),
          Text(
            rightText,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile2(String leftText, Widget rightText) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 15,
            ),
          ),
          rightText,
        ],
      ),
    );
  }

  Widget getIDCard(String content) {
    return Container(
      height: 64.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF04C6B3),
          width: 1.0,
        ),
        color: const Color(0x1A04C6B3),
      ),
      child: Center(
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF04C6B3),
          ),
        ),
      ),
    );
  }
}
