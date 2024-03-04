


// push function

import 'package:flutter/material.dart';

Future<T?> push<T>(BuildContext context, Widget page) async{
  return await Navigator.push<T>(context, MaterialPageRoute(builder: (context) => page));
}