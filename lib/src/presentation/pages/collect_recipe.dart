import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagents_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe_reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/warehouse.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/warehouse_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class CollectRecipe extends StatefulWidget {
  const CollectRecipe({super.key});

  @override
  State<CollectRecipe> createState() => _CollectRecipStateState();
}

class _CollectRecipStateState extends State<CollectRecipe> {
  final List<ReagentsRecipe> _reagentsRecipe = [];
  Reagent? _selectedReagent;
  ReadyRecipeModel? _selectedReadyRecipe;
  int? _quantity;
  bool _isEnough = true;
  bool _isEnoughAll = true;
  bool _isConfirmation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: _buildAppBar(),
      body: _buildReagentsRecipe(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Собрать',
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

  Widget _buildReagentsRecipe() {
    return Column(
      children: [
        Expanded(child: _buildResources()),
        _buildInterfaceReagentsRecipe()
      ],
    );
  }

  Widget _buildResources() {
    if (_reagentsRecipe.isEmpty) {
      return const Center(
        child: Text(
          'Добавьте реагент',
          style: TextStyle(fontSize: 28),
        ),
      );
    }

    return ListView.builder(
      itemCount: _reagentsRecipe.length,
      itemBuilder: (context, index) {
        ReagentsRecipe element = _reagentsRecipe[index];
        return Dismissible(
          key: UniqueKey(),
          child: Card(
            color: const Color.fromARGB(255, 239, 246, 255),
            child: ListTile(
              title: FutureBuilder<Reagent>(
                future: ReagentRepository().getReagentById(element.reagentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}');
                  } else {
                    return _buildReagentInfo(element.quantity, snapshot.data!);
                  }
                },
              ),
              subtitle: _buildQuantityInfo(element),
              trailing: IconButton(
                onPressed: () {
                  _showUpdateReagentsRecipeDialog(element, index);
                },
                icon: const Icon(Icons.change_circle_rounded, size: 40),
              ),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              _reagentsRecipe.removeAt(index);
            });
          },
        );
      },
    );
  }

  Widget _buildReagentInfo(int reagentQuantity, Reagent reagent) {
    return FutureBuilder<WarehouseModel?>(
      future: WarehouseRepository().getElementByReagentId(reagent.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          WarehouseModel? warehouse = snapshot.data;
          _countingReagents(warehouse?.quantity, reagentQuantity);
          String reagentInfo = '${reagent.formula} • ${reagent.name}';

          if (_isEnough) {
            return Text(reagentInfo, style: const TextStyle(fontSize: 21));
          } else {
            return Text(reagentInfo,
                style: const TextStyle(color: Colors.red, fontSize: 21));
          }
        }
      },
    );
  }

  int _countingReagents(int? warehouseQuantity, int recipeQuantity) {
    warehouseQuantity ??= 0;
    int finalQuantity = warehouseQuantity - recipeQuantity;

    if (finalQuantity < 0) {
      _isEnough = false;
    } else {
      _isEnough = true;
    }

    return finalQuantity;
  }

  Widget _buildQuantityInfo(ReagentsRecipe reagent) {
    return FutureBuilder<WarehouseModel?>(
      future: WarehouseRepository().getElementByReagentId(reagent.reagentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          WarehouseModel? warehouse = snapshot.data;
          String quantityInfo =
              'Рецепт: ${reagent.quantity} • Осталось: ${_countingReagents(warehouse?.quantity, reagent.quantity)}';

          if (_isEnough) {
            return Text(quantityInfo, style: const TextStyle(fontSize: 17));
          } else {
            return Text(quantityInfo,
                style: const TextStyle(color: Colors.red, fontSize: 17));
          }
        }
      },
    );
  }

  void _showUpdateReagentsRecipeDialog(ReagentsRecipe element, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Введите количество'),
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
                  child: _buildUpdateReagentsRecipeDialogButton(element, index),
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
      decoration: MyWidgets.buildInputDecoration('Введите количество'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildUpdateReagentsRecipeDialogButton(
      ReagentsRecipe element, int index) {
    return ElevatedButton(
      onPressed: () {
        if (_quantity != null) {
          ReagentsRecipe newReagent = ReagentsRecipe(
            reagentId: element.reagentId,
            quantity: _quantity!,
          );
          setState(() {
            _reagentsRecipe[index] = newReagent;
          });
          Navigator.of(context).pop();
        } else {
          MyWidgets.buildErorDialog(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[300],
      ),
      child: const Text(
        'Сохранить',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }

  Widget _buildInterfaceReagentsRecipe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 10, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildReadyRecipesButton(),
          _buildOrderRecipeButton(),
          _buildAddToReagentsRecipeButton()
        ],
      ),
    );
  }

  Widget _buildReadyRecipesButton() {
    return IconButton(
      onPressed: _showReadyRecipesDialog,
      icon: const Icon(Icons.receipt_long_rounded, size: 40),
    );
  }

  void _showReadyRecipesDialog() {
    showDialog(
        context: context,
        builder: (context) {
          _selectedReadyRecipe = null;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Center(child: Text('Вывберите рецепт')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReadyRecipeDropdown(setState),
                ],
              ),
              actions: [_buildAddToReadyRecipeDialogButton()],
            );
          });
        });
  }

  Widget _buildReadyRecipeDropdown(Function setState) {
    return FutureBuilder<List<ReadyRecipeModel>>(
        future: ReadyRecipeRepository().getReadyRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else {
            List<ReadyRecipeModel> readyRecipes = snapshot.data!;
            return DropdownButtonFormField<int>(
              value: _selectedReadyRecipe?.id,
              items: readyRecipes.map((readyRecipe) {
                return DropdownMenuItem<int>(
                  value: readyRecipe.id,
                  child: Text(readyRecipe.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReadyRecipe =
                      readyRecipes.firstWhere((reagent) => reagent.id == value);
                });
              },
              decoration: MyWidgets.buildInputDecoration('Выберите рецепт'),
              isExpanded: true,
            );
          }
        });
  }

  Widget _buildAddToReadyRecipeDialogButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_selectedReadyRecipe != null) {
            _addReagentFromReadyRecipe(_selectedReadyRecipe!.id!);
            Navigator.of(context).pop();
          } else {
            MyWidgets.buildErorDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
        ),
        child: const Text(
          'Добавить рецепт',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }

  Future<void> _addReagentFromReadyRecipe(int readyRecipeId) async {
    List<Map<String, dynamic>> reagents = await ReadyRecipeReagentRepository()
        .getReagentsForReadyRecipe(readyRecipeId);

    for (int i = 0; i < reagents.length; i++) {
      int reagentId = reagents[i]['reagent_id'] as int;
      int quantity = reagents[i]['quantity'] as int;

      _checkingAddingReagent(reagentId, quantity);
    }
  }

  void _checkingAddingReagent(int reagentId, int reagentQuantity) {
    int existingIndex = _reagentsRecipe.indexWhere((element) => element.reagentId == reagentId);

    if (existingIndex != -1) {
      setState(() {
        _reagentsRecipe[existingIndex].quantity += reagentQuantity;
      });
    } else {
      ReagentsRecipe newReagent = ReagentsRecipe(
        reagentId: reagentId,
        quantity: reagentQuantity,
      );
      setState(() {
        _reagentsRecipe.add(newReagent);
      });
    }
  }

  Widget _buildOrderRecipeButton() {
    return ElevatedButton(
        onPressed: () {
          if (_reagentsRecipe.isNotEmpty) {
            _addRecipeReagent(_reagentsRecipe);
          } else {
            MyWidgets.buildErorDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
        ),
        child: const Text(
          'Оформить рецепт',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ));
  }

  Future<void> _addRecipeReagent(List<ReagentsRecipe> reagentsRecipe) async {
    await _checkEnoughReagents(reagentsRecipe);

    if (!_isConfirmation) {
      return;
    }

    RecipeModel recipe = RecipeModel(isAccepted: false, isEnough: _isEnoughAll);
    int recipeId = await RecipeRepository().insertRecipe(recipe);

    for (var element in reagentsRecipe) {
      RecipeReagent recipeReagent = RecipeReagent(
          recipeId: recipeId,
          reagentId: element.reagentId,
          quantity: element.quantity);
      await RecipeReagentRepository().insertRecipeReagent(recipeReagent);
    }

    await _warehouseManagement(recipe, recipeId);

    setState(() {
      reagentsRecipe.clear();
    });
  }

  Future<void> _checkEnoughReagents(List<ReagentsRecipe> reagentsRecipe) async {
    _isEnoughAll = true;
    for (int i = 0; i < reagentsRecipe.length; i++) {
      WarehouseModel? warehouseModel = await WarehouseRepository()
          .getElementByReagentId(reagentsRecipe[i].reagentId);
      if (warehouseModel == null ||
          warehouseModel.quantity < reagentsRecipe[i].quantity) {
        _isEnoughAll = false;
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
            content: const Text(
                'В вашем списке есть элемент с превышающим количеством'),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: () {
                    _isConfirmation = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _isConfirmation = false;
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Отменить',
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
      List<Map<String, dynamic>> reagents =
          await RecipeReagentRepository().getReagentsForRecipe(recipeId);

      for (int i = 0; i < reagents.length; i++) {
        int reagentId = reagents[i]['reagent_id'] as int;
        int quantity = reagents[i]['quantity'] as int;

        WarehouseModel? warehouse =
            await WarehouseRepository().getElementByReagentId(reagentId);
        WarehouseModel newWarehouse = WarehouseModel(
            id: warehouse!.id,
            reagentId: warehouse.reagentId,
            quantity: warehouse.quantity - quantity);
        await WarehouseRepository().updateElement(newWarehouse);
      }
    }
  }

  Widget _buildAddToReagentsRecipeButton() {
    return IconButton(
      onPressed: _showAddToReagentsRecipeDialog,
      icon: const Icon(
        Icons.add_rounded,
        size: 40,
      ),
    );
  }

  void _showAddToReagentsRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        _selectedReagent = null;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Добавление в рецепт'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReagentDropdown(setState),
                  _buildQuantityTextField(setState),
                ],
              ),
              actions: [
                _buildAddToReagentsRecipeDialogButton(),
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
              value: _selectedReagent?.id,
              items: reagents.map((reagent) {
                return DropdownMenuItem<int>(
                  value: reagent.id,
                  child: Text(reagent.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReagent = reagents.firstWhere((reagent) => reagent.id == value);
                });
              },
              decoration: MyWidgets.buildInputDecoration('Выберите реагент'),
              isExpanded: true,
            );
          }
        });
  }

  Widget _buildQuantityTextField(Function setState) {
    return TextField(
      decoration: MyWidgets.buildInputDecoration('Количество'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildAddToReagentsRecipeDialogButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_selectedReagent != null && _quantity != null) {
            _checkingAddingReagent(_selectedReagent!.id!, _quantity!);
            Navigator.of(context).pop();
          } else {
            MyWidgets.buildErorDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
        ),
        child: const Text(
          'Добавить в рецепт',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}
