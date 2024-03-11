import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_transfer/data/transfer_data.dart';
import 'package:safe_transfer/utils/encrypt_service.dart';
import 'package:safe_transfer/utils/functions.dart';
import 'package:safe_transfer/widgets/custom_app_bar.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  List<String> _pictures = [];

  bool isScanning = false;

  bool? isDataMatching;

  bool loading = false;

  void _getDocument() async {
    try {
      final pictures = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: true,
      );
      if (!mounted) return;
      if (pictures?.isEmpty == true || pictures == null) {
        return;
      }
      setState(() {
        _pictures = pictures;
      });
      _checker();
    } catch (exception) {
      debugPrint('Exception: $exception');
    }
  }

  // this function confirm the transfer
  Future<void> _confirmTransfer(TransferData data) async {
    showLoadingDialog(context, 'Confirming Transfer...');
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('createTransaction');
    final HttpsCallableResult result = await callable.call({
      'status': 'accepted',
      'id': data.id,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'accountNumber': data.accountNumber,
      'sortCode': data.sortCode,
      'amount': data.amount,
      'name': data.name,
    });
    debugPrint('Result: ${result.data}');
    if( result.data['status'] == 'accepted' ){
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/home');
      await Future.delayed(const Duration(milliseconds: 500));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer confirmed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to confirm transfer! Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _declineTransfer(TransferData data) async {
    showLoadingDialog(context, 'Declining Transfer...');
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('createTransaction');
    final HttpsCallableResult result = await callable.call({
      'status': 'rejected',
      'id': data.id,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'accountNumber': data.accountNumber,
      'sortCode': data.sortCode,
      'amount': data.amount,
      'name': data.name,
    });
    debugPrint('Result: ${result.data}');
    if( result.data['status'] == 'rejected' ){
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/home');
      await Future.delayed(const Duration(milliseconds: 500));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer declined'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to decline transfer! Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  initState() {
    super.initState();
    _getDocument();
  }

  @override
  dispose() {
    super.dispose();
  }

  _checker() async {
    setState(() {
      isScanning = true;
    });
    final res =
        await ImageDetectionService.isDataMatching(File(_pictures.first));
    setState(() {
      isScanning = false;
    });
    if (res['data'] != null) {
      final data = res['data'] as TransferData;
      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return BottomInfoDialog(
            scannedData: data,
            onRescan: _getDocument,
            onConfirm: () {
              _confirmTransfer(data);
            },
            onCancel: () {
              _declineTransfer(data);
            },
          );
        },
      );
      return;
    }

    if (res['error'] != null) {
      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return FailedToMatchDataDialog(
            title: res['error'],
            fieldsNotMatching: List<String>.from(
              res['notMatchingList'] ?? [],
            ),
            onRescan: _getDocument,
          );
        },
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Authentication',
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_pictures.isNotEmpty)
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _getDocument,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  fixedSize: const Size(double.infinity, 40),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                child: const Text('Change Document'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // rescan button
                            ElevatedButton(
                              onPressed: () async {
                                if (isScanning) return;
                                _checker();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C3B1),
                                foregroundColor: Colors.white,
                                fixedSize: const Size(100, 40),
                                padding: EdgeInsets.zero,
                                alignment: Alignment.center,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              child: isScanning
                                  ? const Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                  )
                                  : const Text('Rescan ↻'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Image.file(
                            width: double.infinity,
                            File(_pictures.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isDataMatching == true)
                Row(
                  children: [
                    // confirm transfer
                    // cancel transfer
                    IconButton(
                      onPressed: () {
                        // cancel transfer
                      },
                      icon: const Icon(Icons.cancel),
                      iconSize: 45,
                      color: Colors.red,
                    ),
                    const Expanded(
                      child: Text(
                        'Transfer Data Matching',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // confirm transfer
                      },
                      iconSize: 45,
                      color: Colors.green,
                      icon: const Icon(
                        Icons.check,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
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
                        transferData.amount.toStringAsFixed(2),
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

  Widget _buildIconButton(
      {required Color buttonColor, required String iconPath}) {
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

class BottomInfoDialog extends StatelessWidget {
  final TransferData scannedData;
  final void Function()? onRescan;
  final void Function()? onConfirm;
  final void Function()? onCancel;
  const BottomInfoDialog(
      {super.key,
      required this.scannedData,
      this.onRescan,
      this.onConfirm,
      this.onCancel});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scanned Information',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              DataInfo(
                subTitle: 'Amount',
                title: '£${scannedData.amount.toStringAsFixed(2)}',
                titleFontSize: 35,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DataInfo(
                    subTitle: 'Name',
                    title: scannedData.name,
                  ),
                  DataInfo(
                    subTitle: 'Sort Code',
                    title: scannedData.sortCode,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DataInfo(
                subTitle: 'Account Number',
                title: scannedData.accountNumber,
              ),
              const SizedBox(height: 20),
              DataInfo(
                subTitle: 'ID',
                title: scannedData.id,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  DataIcon(
                    icon: Icons.close,
                    color: const Color(0xFFFF5555),
                    onTap: () {
                      onCancel?.call();
                    },
                  ),
                  const Expanded(child: SizedBox()),
                  DataIcon(
                    icon: Icons.refresh_outlined,
                    color: Colors.black,
                    onTap: () {
                      Navigator.of(context).pop();
                      onRescan?.call();
                    },
                  ),
                  const Expanded(child: SizedBox()),
                  DataIcon(
                    icon: Icons.check,
                    color: const Color(0xFF00C3B1),
                    onTap: () {
                      onConfirm?.call();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class DataIcon extends StatelessWidget {
  final void Function()? onTap;
  final IconData icon;
  final Color color;
  const DataIcon(
      {super.key, this.onTap, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DataInfo extends StatelessWidget {
  final String title;
  final String subTitle;
  final double titleFontSize;
  const DataInfo(
      {super.key,
      required this.title,
      required this.subTitle,
      this.titleFontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            color: const Color(0xFF00C3B1),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subTitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// failured to match the data bottom sheet dialog
class FailedToMatchDataDialog extends StatelessWidget {
  final List<String> fieldsNotMatching;
  final String? title;
  final void Function()? onRescan;
  const FailedToMatchDataDialog(
      {super.key, required this.fieldsNotMatching, this.onRescan, this.title});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Failed to Match Data',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
              Text(
                title ??
                    'The scanned data does not match the data in the system.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              if (fieldsNotMatching.isNotEmpty) ...[
                const Text(
                  'Fields Not Matching',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: fieldsNotMatching
                      .map((field) => Chip(
                            label: Text(
                              field,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: const Color(0xFFFF5555),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DataIcon(
                    icon: Icons.refresh_outlined,
                    color: Colors.black,
                    onTap: () {
                      Navigator.of(context).pop();

                      onRescan?.call();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
