import 'package:accounting_chemical_reagents/src/presentation/pages/login.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/order.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/registration.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/warehouse.dart';
import 'package:flutter/material.dart';

void main() async {
  
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => const Login(),
      '/registration': (context) => const Registration(),
      '/order': (context) => const Order(),
      '/warehouse':(context) => Warehouse(),
    },
  ));
}
