import 'package:accounting_chemical_reagents/src/presentation/pages/login.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/order.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/registration.dart';
import 'package:flutter/material.dart';

void main() async {
  
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => Login(),
      '/registration': (context) => Registration(),
      '/order': (context) => Order(),
      //'/warehouse':(context) => Warehouse(),
    },
  ));
}
