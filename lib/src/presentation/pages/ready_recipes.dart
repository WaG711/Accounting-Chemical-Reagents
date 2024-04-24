import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/add_ready_recipe.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class ReadyRecipe extends StatefulWidget {
  const ReadyRecipe({super.key});

  @override
  State<ReadyRecipe> createState() => _ReadyRecipeState();
}

class _ReadyRecipeState extends State<ReadyRecipe> {
  late Future<List<ReadyRecipeModel>> _fetchReadyRecipesFuture;

  @override
  void initState() {
    super.initState();
    _fetchReadyRecipesFuture = _fetchReadyRecipesData();
  }

  Future<List<ReadyRecipeModel>> _fetchReadyRecipesData() async {
    return ReadyRecipeRepository().getReadyRecipes();
  }

  void _refreshReadyRecipesData() {
    setState(() {
      _fetchReadyRecipesFuture = _fetchReadyRecipesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: _buildReadyRecipes()),
          _buildAddReadyRecipesButton()
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Готовые рецепты',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildReadyRecipes() {
    return Column(
      children: [
        Expanded(
            child: FutureBuilder<List<ReadyRecipeModel>>(
          future: _fetchReadyRecipesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Ошибка: ${snapshot.error}');
            } else {
              List<ReadyRecipeModel>? readyRecipes = snapshot.data;
              if (readyRecipes == null || readyRecipes.isEmpty) {
                return const Center(
                  child: Text(
                    'Пусто',
                    style: TextStyle(fontSize: 28),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: readyRecipes.length,
                  itemBuilder: (context, index) {
                    ReadyRecipeModel readyRecipe = readyRecipes[index];
                    return ExpansionTile(
                      title: Text(
                        readyRecipe.name,
                        style: const TextStyle(fontSize: 22),
                      ),
                      children: [_showRecipeInfo(readyRecipe)],
                    );
                  },
                );
              }
            }
          },
        ))
      ],
    );
  }

  Widget _showRecipeInfo(ReadyRecipeModel readyRecipe) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReagentsInfo(readyRecipe.id!),
        Center(
          child: _buildDeleteReadyRecipeButton(readyRecipe),
        )
      ],
    );
  }

  Widget _buildReagentsInfo(int readyRecipeId) {
    return FutureBuilder(
      future: _getReagentsInfo(readyRecipeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          return Text('${snapshot.data}', style: const TextStyle(fontSize: 24));
        }
      },
    );
  }

  Future<String> _getReagentsInfo(int readyRecipeId) async {
    List<Map<String, dynamic>> reagents = await ReadyRecipeReagentRepository().getReagentsForReadyRecipe(readyRecipeId);
    String reagentsInfo = '';

    for (int i = 0; i < reagents.length; i++) {
      int reagentId = reagents[i]['reagent_id'] as int;
      int quantity = reagents[i]['quantity'] as int;

      Reagent reagent = await ReagentRepository().getReagentById(reagentId);
      reagentsInfo += '${reagent.name} - $quantity';
      if (i < reagents.length - 1) {
        reagentsInfo += '\n';
      }
    }
    return reagentsInfo;
  }

  Widget _buildDeleteReadyRecipeButton(ReadyRecipeModel recipe) {
    return ElevatedButton(
      onPressed: () {
        ReadyRecipeRepository().deleteReadyRecipe(recipe.id!);
        ReadyRecipeReagentRepository().deleteReadyRecipeReagents(recipe.id!);
        _refreshReadyRecipesData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[300],
      ),
      child: const Text(
        'Удалить',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }

  Widget _buildAddReadyRecipesButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 10, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const AddReadyRecipe(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
              ),
              child: const Text(
                'Добавить готовый рецепт',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ))
        ],
      ),
    );
  }
}
