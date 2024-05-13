import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/data/transfer_data.dart';
import 'package:safe_transfer/widgets/custom_button.dart';

part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  TransferCubit() : super(TransferInitial());

  void createTransfer({
    required String payeeFullName,
    required String? sortCode,
    required String accountNumber,
    required double amount,
    required double balance,
    required BuildContext context,
  }) async {
    if (balance < amount) {
      emit(TransferError(message: 'Insufficient funds'));
      return;
    }

    if (await checkTransferNotExist(accountNumber)) {
      AwesomeDialog(
        // ignore: use_build_context_synchronously
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Fraud Alert',
        showCloseIcon: false,
        //btnCancel:  const SizedBox(),
        titleTextStyle: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        desc:
            "Don't fall victim to a scam. Criminals pretend to be people you trust, like a company you'd pay bills to, UCL or even the police.UCL will never ask you to move money, but criminals will.",
        btnOk: CustomButton(
          text: 'Save',
          onPressed: () {
            Navigator.of(context).pop();
            _createTransfer(
              payeeFullName: payeeFullName,
              sortCode: sortCode,
              accountNumber: accountNumber,
              amount: amount,
              balance: balance,
            );
          },
        ),
      ).show();
    } else {
      _createTransfer(
        payeeFullName: payeeFullName,
        sortCode: sortCode,
        accountNumber: accountNumber,
        amount: amount,
        balance: balance,
      );
    }
  }

  void _createTransfer({
    required String payeeFullName,
    required String? sortCode,
    required String accountNumber,
    required double amount,
    required double balance,
  }) async {
    try {
      emit(TransferLoading());
      // generate custom document id with timestamp
      final microseconds = DateTime.now().microsecondsSinceEpoch;
      final ref = FirebaseFirestore.instance
          .collection('transfers')
          .doc(microseconds.toString());
      final data = await _callEncryptFunction({
        'payeeFullName': payeeFullName,
        'sortCode': sortCode,
        'accountNumber': accountNumber,
        'amount': amount,
        'id': ref.id,
      });
      createTransferWithFunction({
        'payeeFullName': payeeFullName,
        'sortCode': sortCode,
        'accountNumber': accountNumber,
        'amount': amount,
        'id': ref.id,
        'status': 'created',
        'createdAt': Timestamp.now().millisecondsSinceEpoch,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'encryptedData': data,
      });
      emit(TransferCreated(
        encryptedData: data,
        model: TransferData(
          amount: amount,
          name: payeeFullName,
          sortCode: sortCode.toString(),
          accountNumber: accountNumber,
          id: ref.id,
          encryptedData: data,
          status: 'initiated',
        ),
      ));
    } on FirebaseFunctionsException catch (e) {
      debugPrint("Function ${e.message}");
      emit(TransferError(message: e.message!));
    } on FirebaseException catch (e) {
      debugPrint("Firebase ${e.message}");
      emit(TransferError(message: e.message!));
    } catch (e) {
      debugPrint("Error $e");
      emit(TransferError(message: e.toString()));
    }
  }

  Future<String> _callEncryptFunction(Map<String, dynamic> jsonData) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('encryptData');
    final HttpsCallableResult result = await callable.call(jsonData);
    debugPrint("====> Result data encrypted ${result.data.length}");
    return result.data;
  }

  // create transfer with firebase function
  Future<void> createTransferWithFunction(Map<String, dynamic> data) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createTransaction');
      final HttpsCallableResult result = await callable.call(data);
      debugPrint("====> Result data ${result.data}");
    } catch (e) {
      debugPrint("Error $e");
    }
  }
}

// function check if transfer already send ( Check account number already exist in the transfer collection)
Future<bool> checkTransferNotExist(String accountNumber) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('transfers')
      .where('accountNumber', isEqualTo: accountNumber)
      .get();
  return snapshot.docs.isEmpty;
}
