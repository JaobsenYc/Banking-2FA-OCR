


// push function

import 'package:flutter/material.dart';

Future<T?> push<T>(BuildContext context, Widget page) async{
  return await Navigator.push<T>(context, MaterialPageRoute(builder: (context) => page));
}

// push named function
Future<T?> pushNamed<T>(BuildContext context, String routeName) async{
  return await Navigator.pushNamed<T>(context, routeName);
}

// push replacement function
Future<T?> pushReplacement<T>(BuildContext context, Widget page) async{
  return await Navigator.pushAndRemoveUntil<T>(context, MaterialPageRoute(builder: (context) => page), (route) => false);
}

// show loading dialog
void showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        content: Row(
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      );
    },
  );
}