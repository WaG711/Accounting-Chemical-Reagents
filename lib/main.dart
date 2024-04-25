import 'package:accounting_chemical_reagents/src/domain/database_helper.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/entrance.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/recipe_base.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/warehouse.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initDatabase();

  runApp(MaterialApp(
    title: 'СУХР',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const Entrance(),
      '/recipe': (context) => const RecipeBase(),
      '/warehouse': (context) => const Warehouse(),
    },
  ));
}
