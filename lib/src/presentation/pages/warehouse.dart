import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/warehouse.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/warehouse_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class Warehouse extends StatefulWidget {
  const Warehouse({super.key});

  @override
  State<Warehouse> createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {
  late Future<List<WarehouseModel>> _fetchWarehouseFuture;
  late Future<List<RecipeModel>> _fetchRecipesFuture;
  Reagent? selectedReagent;
  int? quantity;

  @override
  void initState() {
    super.initState();
    _fetchWarehouseFuture = _fetchWarehouseData();
    _fetchRecipesFuture = _fetchRecipesData();
  }

  Future<List<WarehouseModel>> _fetchWarehouseData() async {
    return WarehouseRepository().getElements();
  }

  void _refreshWarehouseData() {
    setState(() {
      _fetchWarehouseFuture = _fetchWarehouseData();
    });
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
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildWaitingRecipes()),
          Expanded(child: _buildWarehouseResources()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Склад',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green[300],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildWaitingRecipes() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Ожидающие рецепты',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Expanded(
            child: FutureBuilder<List<RecipeModel>>(
          future: _fetchRecipesFuture,
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
                      title: Text('№${recipe.id}',
                      style: const TextStyle(fontSize: 22),),
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

  Widget _buildWarehouseResources() {
    return Column(
      children: [
        _buildInterfaceWarehouseResource(),
        Expanded(child: _buildResources())
      ],
    );
  }

  Widget _buildInterfaceWarehouseResource() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ресурсы на складе',
            style: TextStyle(fontSize: 22),
          ),
          _buildAddToWarehouseButton(),
        ],
      ),
    );
  }

  Widget _buildAddToWarehouseButton() {
    return ElevatedButton(
      onPressed: _showAddToWarehouseDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
      ),
      child: const Text(
        'Добавить на склад',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16),
      ),
    );
  }

  void _showAddToWarehouseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        selectedReagent = null;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Добавление на склад'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReagentDropdown(setState),
                  _buildQuantityTextField(setState),
                ],
              ),
              actions: [
                _buildAddToWarehouseDialogButton(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReagentDropdown(Function setState) {
    return FutureBuilder<List<Reagent>>(
      future: ReagentRepository().getReagents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          List<Reagent> reagents = snapshot.data!;
          return DropdownButtonFormField<int>(
            value: selectedReagent?.id,
            items: reagents.map((reagent) {
              return DropdownMenuItem<int>(
                value: reagent.id,
                child: Text(reagent.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedReagent = reagents.firstWhere((reagent) => reagent.id == value);
              });
            },
            decoration: const InputDecoration(
              labelText: 'Выберите реагент',
            ),
          );
        }
      },
    );
  }

  Widget _buildQuantityTextField(Function setState) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Количество',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildAddToWarehouseDialogButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedReagent != null && quantity != null) {
          _addToWarehouse();
          Navigator.of(context).pop();
        } else {
          _showErrorDialog();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
      ),
      child: const Text(
        'Добавить на склад',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }

  Future<void> _addToWarehouse() async {
    WarehouseModel? existingWarehouse = await WarehouseRepository().getElementByReagentId(selectedReagent!.id!);

    if (existingWarehouse != null) {
      WarehouseModel warehouse = WarehouseModel(
        id: existingWarehouse.id,
        reagentId: existingWarehouse.reagentId,
        quantity: existingWarehouse.quantity + quantity!,
      );
      WarehouseRepository().updateElement(warehouse);
    } else {
      WarehouseModel warehouse = WarehouseModel(
        reagentId: selectedReagent!.id!,
        quantity: quantity!,
      );
      WarehouseRepository().insertElement(warehouse);
    }
    _refreshWarehouseData();
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: const Text('Все поля должны быть заполнены'),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildResources() {
    return FutureBuilder<List<WarehouseModel>>(
      future: _fetchWarehouseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          List<WarehouseModel>? elements = snapshot.data;
          if (elements == null || elements.isEmpty) {
            return const Center(
              child: Text(
                'Пусто',
                style: TextStyle(fontSize: 28),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: elements.length,
              itemBuilder: (context, index) {
                WarehouseModel element = elements[index];
                return Dismissible(
                  key: UniqueKey(),
                  child: Card(
                    child: ListTile(
                      title: FutureBuilder<Reagent>(
                        future: ReagentRepository().getReagentById(element.reagentId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Ошибка: ${snapshot.error}');
                          } else {
                            return Text('${snapshot.data!.name} - ${snapshot.data!.formula}');
                          }
                        },
                      ),
                      subtitle: Text('Количество: ${element.quantity}'),
                      trailing: IconButton(
                        onPressed: () {
                          _showUpdateWarehouseDialog(element);
                        },
                        icon: const Icon(Icons.add_home_rounded, size: 40),
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    WarehouseRepository().deleteElement(element.id!);
                    _refreshWarehouseData();
                  },
                );
              },
            );
          }
        }
      },
    );
  }

  void _showUpdateWarehouseDialog(WarehouseModel element) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Прибавление количества'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Актуальное количество: ${element.quantity}'),
                  _buildUpdateQuantityTextField(setState),
                ],
              ),
              actions: [
                Center(
                  child: _buildUpdateWarehouseDialogButton(element),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUpdateQuantityTextField(Function setState) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Прибавить на',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildUpdateWarehouseDialogButton(WarehouseModel element) {
    return ElevatedButton(
      onPressed: () {
        if (quantity != null) {
          WarehouseModel warehouse = WarehouseModel(
            id: element.id,
            reagentId: element.reagentId,
            quantity: element.quantity + quantity!,
          );
          WarehouseRepository().updateElement(warehouse);
          _refreshWarehouseData();
          Navigator.of(context).pop();
        } else {
          _showErrorDialog();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
      ),
      child: const Text(
        'Прибавить',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}
