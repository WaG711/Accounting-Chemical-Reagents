import 'package:accounting_chemical_reagents/src/presentation/widgets/buildDrawer.dart';
import 'package:flutter/material.dart';

class Warehouse extends StatelessWidget {
  const Warehouse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Склад'),
      ),
      endDrawer: buildDrawer(context),
      //body: Form(),
    );
  }
}