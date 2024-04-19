import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class ReadyRecipe extends StatefulWidget {
  const ReadyRecipe({super.key});

  @override
  State<ReadyRecipe> createState() => _ReadyRecipeState();
}

class _ReadyRecipeState extends State<ReadyRecipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
      body: Container(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Готовые рецепты',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue[300],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
