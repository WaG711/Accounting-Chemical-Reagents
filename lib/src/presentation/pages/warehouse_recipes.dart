import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class WarehouseRecipes extends StatefulWidget {
  const WarehouseRecipes({super.key});

  @override
  State<WarehouseRecipes> createState() => _WarehouseRecipesState();
}

class _WarehouseRecipesState extends State<WarehouseRecipes> {
  late Future<List<RecipeModel>> _fetchRecipesFuture;

  @override
  void initState() {
    super.initState();
    _fetchRecipesFuture = _fetchRecipesData();
  }

  Future<List<RecipeModel>> _fetchRecipesData() async {
    return RecipeRepository().getRecipesAcceptedFalse();
  }

  void _refreshRecipesData() {
    setState(() {
      _fetchRecipesFuture = _fetchRecipesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder<List<RecipeModel>>(
            future: _fetchRecipesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.green[300]));
              } else if (snapshot.hasError) {
                return Text('Ошибка: ${snapshot.error}');
              } else {
                List<RecipeModel>? recipes = snapshot.data;
                if (recipes == null || recipes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Пусто',
                      style: TextStyle(fontSize: 28),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      RecipeModel recipe = recipes[index];
                      return ExpansionTile(
                        title: Text(
                          '№${recipe.id}',
                          style: const TextStyle(fontSize: 22),
                        ),
                        childrenPadding:
                            const EdgeInsets.symmetric(horizontal: 15.0),
                        children: [_showRecipeInfo(recipe)],
                      );
                    },
                  );
                }
              }
            },
          ))
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Рецепты',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            MyWidgets.openBottomDrawer(context);
          },
        ),
      ],
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _showRecipeInfo(RecipeModel recipe) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReagentsInfo(recipe.id!),
        Center(
          child: _buildUpdateRecipeButton(recipe),
        )
      ],
    );
  }

  Widget _buildReagentsInfo(int recipeId) {
    return FutureBuilder(
      future: _getReagentsInfo(recipeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: Colors.green[300]);
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          return Text('${snapshot.data}', style: const TextStyle(fontSize: 24));
        }
      },
    );
  }

  Future<String> _getReagentsInfo(int recipeId) async {
    List<Map<String, dynamic>> reagents = await RecipeReagentRepository().getReagentsForRecipe(recipeId);
    String reagentsInfo = '';

    for (int i = 0; i < reagents.length; i++) {
      int reagentId = reagents[i]['reagent_id'] as int;
      int quantity = reagents[i]['quantity'] as int;

      Reagent reagent = await ReagentRepository().getReagentById(reagentId);
      reagentsInfo += '${reagent.name} • $quantity';
      if (i < reagents.length - 1) {
        reagentsInfo += '\n';
      }
    }
    return reagentsInfo;
  }

  Widget _buildUpdateRecipeButton(RecipeModel recipe) {
    RecipeModel processedRecipe = RecipeModel(id: recipe.id, isAccepted: true, isEnough: true);
    return ElevatedButton(
      onPressed: () {
        RecipeRepository().updateRecipe(processedRecipe);
        _refreshRecipesData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
      ),
      child: const Text(
        'Оформить',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}
