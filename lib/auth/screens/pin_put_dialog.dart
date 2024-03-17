import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class CodeConfirmDialog extends StatelessWidget {
  final String phoneNumber;
  final void Function(String) onDoneEditing;
  const CodeConfirmDialog({super.key, required this.phoneNumber, required this.onDoneEditing});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We sent a code to $phoneNumber',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            const Text(
              'Enter the code sent to your phone',
              style: TextStyle(fontSize: 15.0, color: Color(0xff999999)),
            ),
            const SizedBox(height: 15.0),
            Pinput(
              length: 6,
              onCompleted: (value) {
                onDoneEditing(value);
              },
            ),
            const SizedBox(height: 15.0),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }}