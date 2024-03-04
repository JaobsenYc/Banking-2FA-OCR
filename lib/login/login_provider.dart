import 'package:flutter/material.dart';
import 'package:safe_transfer/utils/firebase_auth_service.dart';

class LoginProvider extends ChangeNotifier {
  bool? _loading;

  bool? get loading => _loading;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    _loading = true;
    notifyListeners();
    final res =
        await FirebaseAuthService.signInWithEmailAndPassword(email, password);
    _loading = false;
    if (res == true) {
      _errorMessage = null;
    }
    if (res is String) {
      _errorMessage = res;
    } else {
      _errorMessage = "An error occurred. Please try again later";
    }
    notifyListeners();
  }
}
