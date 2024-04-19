import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class CollectRecipe extends StatefulWidget {
  const CollectRecipe({super.key});

  @override
  State<CollectRecipe> createState() => _CollectRecipStateState();
}

class _CollectRecipStateState extends State<CollectRecipe> {
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
        'Собрать рецепт',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue[300],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}