import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  TransferCubit() : super(TransferInitial());

  void createTransfer(
      {required String payeeFullName,
      required int? sortCode,
      required String accountNumber,
      required double amount}) async {
    try {
      emit(TransferLoading());

      final data = await _callEncryptFunction({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'payeeFullName': payeeFullName,
        'sortCode': sortCode,
        'accountNumber': accountNumber,
        'amount': amount,
        'status': 'initiated',
        'type': 'expense',
        'lastScannedDate': null,
        'createdAt': DateTime.now().toIso8601String(),
      });

/*       final ref = await FirebaseFirestore.instance.collection('transfers').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'payeeFullName': payeeFullName,
        'sortCode': sortCode,
        'accountNumber': accountNumber,
        'amount': amount,
        'status': 'initiated',
        'type': 'expense',
        'lastScannedDate': null,
        'createdAt': DateTime.now().toIso8601String(),
      }); */
      emit(TransferCreated(
        id: data,
        payeeFullName: payeeFullName,
        sortCode: sortCode ?? 0,
        accountNumber: accountNumber,
        amount: amount,
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
    return result.data;
  }
}
