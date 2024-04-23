import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/warehouse.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/warehouse_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class PendingRecipes extends StatefulWidget {
  const PendingRecipes({super.key});

  @override
  State<PendingRecipes> createState() => _PendingRecipesStateState();
}

class _PendingRecipesStateState extends State<PendingRecipes> {
  late Future<List<RecipeModel>> _fetchEnoughRecipesFuture;
  late Future<List<RecipeModel>> _fetchNoEnoughRecipesFuture;

  @override
  void initState() {
    super.initState();
    _fetchEnoughRecipesFuture = _fetchEnoughRecipesData();
    _fetchNoEnoughRecipesFuture = _fetchNoEnoughRecipesData();
  }

  Future<List<RecipeModel>> _fetchEnoughRecipesData() async {
    return RecipeRepository().getRecipesAcceptedFalse();
  }

  Future<List<RecipeModel>> _fetchNoEnoughRecipesData() async {
    return RecipeRepository().getRecipesFalse();
  }

  void _refreshEnoughRecipesData() {
    setState(() {
      _fetchEnoughRecipesFuture = _fetchEnoughRecipesData();
    });
  }

  void _refreshNoEnoughRecipesData() {
    setState(() {
      _fetchNoEnoughRecipesFuture = _fetchNoEnoughRecipesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildEnoughRecipes()),
          Expanded(child: _buildNoEnoughRecipes()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Ожидающие рецепты',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.grey[100],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildEnoughRecipes() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            'Ожидающие оформления',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Expanded(
            child: FutureBuilder<List<RecipeModel>>(
          future: _fetchEnoughRecipesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
                      children: [_showRecipeInfo(recipe)],
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

  Widget _showRecipeInfo(RecipeModel recipe) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReagentsInfo(recipe.id!),
        Center(
          child: _buildDeleteRecipeButton(recipe),
        )
      ],
    );
  }

  Widget _buildReagentsInfo(int recipeId) {
    return FutureBuilder(
      future: _getReagentsInfo(recipeId),
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

  Future<String> _getReagentsInfo(int recipeId) async {
    List<Map<String, dynamic>> reagents = await RecipeReagentRepository().getReagentsForRecipe(recipeId);
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

  Widget _buildDeleteRecipeButton(RecipeModel recipe) {
    return ElevatedButton(
      onPressed: () {
        _returnQuantityWarehouse(recipe);
        RecipeRepository().deleteRecipe(recipe.id!);
        _refreshEnoughRecipesData();
        _refreshNoEnoughRecipesData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[300],
      ),
      child: const Text(
        'Отменить',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }

  Future<void> _returnQuantityWarehouse(RecipeModel recipe) async {
    if (recipe.isEnough) {
      List<Map<String, dynamic>> reagents = await RecipeReagentRepository().getReagentsForRecipe(recipe.id!);

      for (int i = 0; i < reagents.length; i++) {
        int reagentId = reagents[i]['reagent_id'] as int;
        int quantity = reagents[i]['quantity'] as int;

        WarehouseModel? warehouse = await WarehouseRepository().getElementByReagentId(reagentId);
        WarehouseModel newWarehouse = WarehouseModel(
            id: warehouse!.id,
            reagentId: warehouse.reagentId,
            quantity: warehouse.quantity + quantity);
        await WarehouseRepository().updateElement(newWarehouse);
      }
    }

    await RecipeReagentRepository().deleteRecipeReagents(recipe.id!);
  }

  Widget _buildNoEnoughRecipes() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            'Ожидающие ресурсов',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Expanded(
            child: FutureBuilder<List<RecipeModel>>(
          future: _fetchNoEnoughRecipesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
                      children: [_showRecipeInfo(recipe)],
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
}
