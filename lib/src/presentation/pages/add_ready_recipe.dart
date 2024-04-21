import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class AddReadyRecipe extends StatefulWidget {
  const AddReadyRecipe({super.key});

  @override
  State<AddReadyRecipe> createState() => _AddReadyRecipeState();
}

class _AddReadyRecipeState extends State<AddReadyRecipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Добавить готовый рецепт',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue[300],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}