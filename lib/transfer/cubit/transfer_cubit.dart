import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  TransferCubit() : super(TransferInitial());

  void createTransfer(
      {required String payeeFullName,
      required int? sortCode,
      required String accountNumber,
      required String amount}) async {
    try {
      emit(TransferLoading());
      final ref = await FirebaseFirestore.instance.collection('transfers').add({
        'payeeFullName': payeeFullName,
        'sortCode': sortCode,
        'accountNumber': accountNumber,
        'amount': amount,
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
