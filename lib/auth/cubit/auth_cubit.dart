import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  bool isPrimaryDevice = true;

  void signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //_setPrimaryDevice();
      emit(Authenticated(userCredential.user!));
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
      emit(AlreadyAuthenticated());
    } else {
      emit(FirstTimeLogin());
    }
  }

  void signUpWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(Authenticated(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message.toString()));
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
