import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagents_recipe.dart';
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
  bool isOrder = true;

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
                      children: [_showNoEnoughRecipeInfo(recipe)],
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

  Widget _showNoEnoughRecipeInfo(RecipeModel recipe) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNoEnoughRecipeReagentsInfo(recipe.id!),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderRecipeButton(recipe),
              _buildDeleteRecipeButton(recipe)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildNoEnoughRecipeReagentsInfo(int recipeId) {
    return FutureBuilder(
      future: _getNoEnoughRecipeReagentsInfo(recipeId),
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

  Future<String> _getNoEnoughRecipeReagentsInfo(int recipeId) async {
    List<Map<String, dynamic>> reagents = await RecipeReagentRepository().getReagentsForRecipe(recipeId);
    String reagentsInfo = '';

    for (int i = 0; i < reagents.length; i++) {
      int reagentId = reagents[i]['reagent_id'] as int;
      int quantity = reagents[i]['quantity'] as int;

      Reagent reagent = await ReagentRepository().getReagentById(reagentId);
      WarehouseModel? warehouse = await WarehouseRepository().getElementByReagentId(reagentId);

      if (warehouse != null) {
        reagentsInfo += '${reagent.name} • $quantity/${warehouse.quantity}';
      } else {
        reagentsInfo += '${reagent.name} • $quantity/0';
      }

      if (i < reagents.length - 1) {
        reagentsInfo += '\n';
      }
    }
    return reagentsInfo;
  }

  Widget _buildOrderRecipeButton(RecipeModel recipe) {
    return ElevatedButton(
        onPressed: () {
          _orderRecipe(recipe);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
        ),
        child: const Text(
          'Оформить',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ));
  }

  Future<void> _orderRecipe(RecipeModel recipe) async {
    List<Map<String, dynamic>> reagents = await RecipeReagentRepository().getReagentsForRecipe(recipe.id!);

    isOrder = true;
    await _checkEnoughReagents(reagents);

    if (!isOrder) {
      return;
    }

    RecipeModel updateRecipe = RecipeModel(id: recipe.id, isAccepted: false, isEnough: true);
    await RecipeRepository().updateRecipe(updateRecipe);

    await _warehouseManagement(updateRecipe, recipe.id!);

    _refreshEnoughRecipesData();
    _refreshNoEnoughRecipesData();
  }

  Future<void> _checkEnoughReagents(List<Map<String, dynamic>> reagents) async {
    List<ReagentsRecipe> reagentsRecipe = [];

    for (int i = 0; i < reagents.length; i++) {
      int reagentId = reagents[i]['reagent_id'] as int;
      int quantity = reagents[i]['quantity'] as int;

      ReagentsRecipe reagentRecipe = ReagentsRecipe(reagentId: reagentId, quantity: quantity);
      reagentsRecipe.add(reagentRecipe);
    }

    for (int i = 0; i < reagentsRecipe.length; i++) {
      WarehouseModel? warehouseModel = await WarehouseRepository().getElementByReagentId(reagentsRecipe[i].reagentId);
      if (warehouseModel == null || warehouseModel.quantity < reagentsRecipe[i].quantity) {
        await _showConfirmationDialog();
        return;
      }
    }
  }

  Future<void> _showConfirmationDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Предупреждение'),
            content: const Text('В вашем списке есть элемент с превышающим количеством'),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    isOrder = false;
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ])
            ],
          );
        });
  }

  Future<void> _warehouseManagement(RecipeModel recipe, int recipeId) async {
    if (recipe.isEnough) {
      List<Map<String, dynamic>> reagents = await RecipeReagentRepository().getReagentsForRecipe(recipeId);

      for (int i = 0; i < reagents.length; i++) {
        int reagentId = reagents[i]['reagent_id'] as int;
        int quantity = reagents[i]['quantity'] as int;

        WarehouseModel? warehouse = await WarehouseRepository().getElementByReagentId(reagentId);
        WarehouseModel newWarehouse = WarehouseModel(
            id: warehouse!.id,
            reagentId: warehouse.reagentId,
            quantity: warehouse.quantity - quantity);
        await WarehouseRepository().updateElement(newWarehouse);
      }
    }
  }
}
