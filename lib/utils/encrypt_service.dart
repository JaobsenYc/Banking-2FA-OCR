import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:safe_transfer/data/transfer_data.dart';

class ImageDetectionService {
  // this function  will have an image and will detetct qr code from it and return the qr code string
  static Future<TransferData?> detectQrCodeFromImage(File image) async {
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





static Future<TransferData?> extractDataFromImage(File image) async {
  try {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String? amount;
    String? accountNumber;
    String? sortCode;
    String? name;
    String? id;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // Check for Amount
        if (line.text.contains('Name')) {
          name = extractName(line.text);
        }
        else if (line.text.contains('Amount')) {
          amount = extractAmount(line.text);
        }
        // Check for Account Number
        else if (line.text.contains('Account number')) {
          accountNumber = extractAccountNumber(line.text);
        }
        // Check for Sort Code
        else if (line.text.contains('Sort code')) {
          sortCode = extractSortCode(line.text);
        }
        // Check for ID
        else if (line.text.contains('ID')) {
          id = extractID(line.text);
        }
      }
    }

    return TransferData(amount: double.tryParse("$amount") ??0, name: name ?? '', sortCode: sortCode ??'', accountNumber: accountNumber ??'', id: id ??'',);
  } catch (e) {
    debugPrint("Error in extracting data from image $e");
    return null;
  }
}

static  String extractAmount(String text) {
  RegExp regExp = RegExp(r'Amount:\s*£?(\d+(?:\.\d+)?)');
  Match? match = regExp.firstMatch(text);
  return match?.group(1) ?? '';
}

static String extractAccountNumber(String text) {
  RegExp regExp = RegExp(r'Account number:\s*(\d+)');
  Match? match = regExp.firstMatch(text);
  return match?.group(1) ?? '';
}


// code always have this format someNubers-someNumbers-someNumbers....
static String extractSortCode(String text) {
  RegExp regExp = RegExp(r'Sort code:\s*(\d{2}-\d{2}-\d{2})');
  Match? match = regExp.firstMatch(text);
  return match?.group(1) ?? '';
}

static String extractID(String text) {
  RegExp regExp = RegExp(r'ID:\s*([a-zA-Z0-9]+)');
  Match? match = regExp.firstMatch(text);
  return match?.group(1) ?? '';
}

// name not contain any special character or number and must be at least 3 characters long
static String extractName(String text) {
  RegExp regExp = RegExp(r'Name:\s*([a-zA-Z]+)');
  Match? match = regExp.firstMatch(text);
  return match?.group(1) ?? '';
}




  static Future<Map<String,dynamic>?> _callDecryptFunction(String? data) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('decryptData');
    final HttpsCallableResult result = await callable.call(data);
    return result.data;
  }
}


