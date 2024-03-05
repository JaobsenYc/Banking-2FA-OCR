import 'package:cloud_firestore/cloud_firestore.dart';
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
      final ref = await FirebaseFirestore.instance.collection('transfers')
      .add({
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
      emit(TransferCreated(
        id: ref.id,
        payeeFullName: payeeFullName,
        sortCode: sortCode ?? 0,
        accountNumber: accountNumber,
        amount: amount,
      ));
    } on FirebaseException catch (e) {
      emit(TransferError(message: e.message!));
    } catch (e) {
      emit(TransferError(message: e.toString()));
    }
  }
}
