import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:safe_transfer/data/transfer_data.dart';

class ImageDetectionService {
  static Future<Map<String, dynamic>?> _callDecryptFunction(
      String? data) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('decryptData');
    final HttpsCallableResult result = await callable.call(data);
    return result.data;
  }

  // this function  check if the data from the 2 functions is matching
  static Future<Map<String, dynamic>> isDataMatching(File image) async {
    Map<String, dynamic> result = {};
    final qrData = await _detectQrCodeFromImage(image);
    // check if the transfer status is not initiated
    final data = await FirebaseFirestore.instance
        .collection('transfers')
        .doc(qrData?.id)
        .get();
    if (data.exists) {
      final status = data.get('status');
      if (status != 'initiated') {
        result['error'] = "Transfer already $status";
        return result;
      }
    }
    final textData = await _extractDataFromImage(image);
    if (qrData == null || textData == null) {
      result['error'] = "No data found in the image";
      return result;
    }
    bool sameName = qrData.name == textData.name;
    bool sameAmount = qrData.amount == textData.amount;
    bool sameAccountNumber = qrData.accountNumber == textData.accountNumber;
    bool sameSortCode = qrData.sortCode == textData.sortCode;
    bool sameID = qrData.id == textData.id;

    /// End of tests
    if (sameName && sameAmount && sameAccountNumber && sameSortCode && sameID) {
      result['data'] = qrData;
      return result;
    }

    result['error'] = "Data not matching";
    // set fields that are not matching in the result
    if (!sameName) {
      result['notMatchingList'] = [...result['notMatchingList'] ?? [], "Name"];
    }
    if (!sameAmount) {
      result['notMatchingList'] = [
        ...result['notMatchingList'] ?? [],
        "Amount"
      ];
    }
    if (!sameAccountNumber) {
      result['notMatchingList'] = [
        ...result['notMatchingList'] ?? [],
        "Account Number"
      ];
    }
    if (!sameSortCode) {
      result['notMatchingList'] = [
        ...result['notMatchingList'] ?? [],
        "Sort Code"
      ];
    }
    if (!sameID) {
      result['notMatchingList'] = [...result['notMatchingList'] ?? [], "ID"];
    }
    return result;
  }

  // this function  will have an image and will detetct qr code from it and return the qr code string
  static Future<TransferData?> _detectQrCodeFromImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final List<BarcodeFormat> formats = [BarcodeFormat.qrCode];
      final barcodeScanner = BarcodeScanner(formats: formats);
      final List<Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);
      if (barcodes.isEmpty) {
        return null;
      }
      final data = barcodes.first.rawValue;
      debugPrint("====> Result data encrypted in qr code  ${data?.length}");
      final decryptedData = await _callDecryptFunction(data);
      if (decryptedData != null) {
        return TransferData.fromJson(decryptedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<TransferData?> _extractDataFromImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String? amount;
      String? accountNumber;
      String? sortCode;
      String? name;
      String? id;

      debugPrint("====> Result data from image  ${recognizedText.text}");

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text;

          if (!text.contains(':')) {
            // check if the text is a pure number and must be at least 8 digits
            if (RegExp(r'^\d{8,}$').hasMatch(text)) {
              accountNumber = text;
            }
            // check if the text is a sort code like this 12-34-56 or infinty of 12-34-56....
            else if (RegExp(r'^\d{2}-\d{2}-\d{2}$').hasMatch(text)) {
              sortCode = text;
            } else if (RegExp(
                    r'^[A-Z]{3,}\s*\d+(?:[.,]\d+)?|(?:\£|\$)\s*\d+(?:[.,]\d+)?$')
                .hasMatch(text)) {
              // remove all the currency symbols and spaces
              String cleanedNumber =
                  text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
              amount = cleanedNumber;
            }
            // check if is a name
            else if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
              name = text;
            }
            // check if is an id is like firestore document id
            else if (RegExp(r'^[a-zA-Z0-9]{20}$').hasMatch(text)) {
              id = text;
            }
          } else if (text.startsWith('ID:')) {
            // remove the ID: from the text
            id = text.replaceAll('ID:', '');
            // remove any space
            id = id.replaceAll(' ', '');
          }
        }
      }
      return TransferData(
        amount: double.tryParse("$amount") ?? 0,
        name: name ?? '',
        sortCode: sortCode ?? '',
        accountNumber: accountNumber ?? '',
        id: id ?? '',
      );
    } catch (e) {
      debugPrint("Error in extracting data from image $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> callDecryptFunction(String? data) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('decryptData');
    final HttpsCallableResult result = await callable.call(data);
    return result.data;
  }
}
