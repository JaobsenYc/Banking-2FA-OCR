import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void signInWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(Authenticated(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message.toString()));
    }on Exception catch (e) {
      emit(AuthError(e.toString()));
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
    }on Exception catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
