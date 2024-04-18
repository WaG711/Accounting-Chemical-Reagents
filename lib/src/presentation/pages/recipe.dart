import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class Recipe extends StatefulWidget {
  const Recipe({super.key});

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Рецепт',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue[300],
          iconTheme: const IconThemeData(color: Colors.white)),
      endDrawer: MyWidgets.buildDrawer(context),
    );
  }
}
