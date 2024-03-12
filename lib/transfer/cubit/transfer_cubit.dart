import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/data/transfer_data.dart';

part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  TransferCubit() : super(TransferInitial());

  void createTransfer({
    required String payeeFullName,
    required String? sortCode,
    required String accountNumber,
    required double amount,
    required double balance,
  }) async {
    try {
      if (balance < amount) {
        emit(TransferError(message: 'Insufficient funds'));
        return;
      }
      emit(TransferLoading());
      // generate custom document id with timestamp
      final microseconds = DateTime.now().microsecondsSinceEpoch;
      final ref = FirebaseFirestore.instance.collection('transfers').doc(microseconds.toString());
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
