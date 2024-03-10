import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:safe_transfer/main.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  bool isPrimaryDevice = true;

  void signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //_setPrimaryDevice();
      emit(Authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message.toString()));
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // check if user is first time login
  void checkFirstTimeLogin() async {
    emit(AuthLoading());
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userData.exists) {
      isPrimaryDevice = userData.get('primaryDeviceId') == deviceInfo.deviceId;
      emit(AuthUserLogin(isPrimaryDevice));
    } else {
      emit(AuthUserLogin(null));
    }
  }

  void signUpWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(Authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message.toString()));
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // function that check if user exist if not it will generate a new user with this info :
  // account Number ( Random 8 digit number to 10 digit number) must be unique
  // balance (Random number between 1000 and 10000)
  // uid from firebase auth
  void handleUserData(bool isPrimaryDevice) async {
    try {
          emit(AuthLoading());
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userData = await userDoc.get();
    if (userData.exists) {
      if (isPrimaryDevice) {
        await userDoc.set(
            {'primaryDeviceId': deviceInfo.deviceId}, SetOptions(merge: true));
      } else if (!isPrimaryDevice) {
        await userDoc.set({'authenticatorDeviceId': deviceInfo.deviceId},
            SetOptions(merge: true));
      }
    } else {
      if (isPrimaryDevice) {
        await userDoc.set({
          'accountNumber': await _generateAccountNumber(),
          'balance': _generateBalance(),
          'primaryDeviceId': deviceInfo.deviceId,
          'expiryDate': _generateExpiryDate(),
        });
      } else if (!isPrimaryDevice) {
        await userDoc.set({
          'accountNumber': await  _generateAccountNumber(),
          'balance': _generateBalance(),
          'authenticatorDeviceId': deviceInfo.deviceId,
          'expiryDate': _generateExpiryDate(),
        });
      }
      emit(Authenticated());
    }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<int> _generateAccountNumber() async {
    int account = int.parse(
        (1000000000 + (DateTime.now().millisecondsSinceEpoch % 1000000000))
            .toString());

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('accountNumber', isEqualTo: account)
        .get();

    if (doc.docs.isNotEmpty) {
      return await _generateAccountNumber();
    }
    return account;
  }

  int _generateBalance() {
    return 1000 + (DateTime.now().millisecondsSinceEpoch % 10000);
  }

  // generate expiry date for the card
  Timestamp _generateExpiryDate() {
    final now = DateTime.now();
    final expiryDate = DateTime(now.year + 3, now.month);
    return Timestamp.fromDate(expiryDate);
  }
}
