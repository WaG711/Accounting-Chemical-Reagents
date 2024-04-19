import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class PendingRecipes extends StatefulWidget {
  const PendingRecipes({super.key});

  @override
  State<PendingRecipes> createState() => _PendingRecipesStateState();
}

class _PendingRecipesStateState extends State<PendingRecipes> {
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
        'Ожидающие рецепты',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue[300],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}