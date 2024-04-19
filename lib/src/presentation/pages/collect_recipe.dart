import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagent_warehouse.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class CollectRecipe extends StatefulWidget {
  const CollectRecipe({super.key});

  @override
  State<CollectRecipe> createState() => _CollectRecipStateState();
}

class _CollectRecipStateState extends State<CollectRecipe> {
  List<ReagentWarehouse> reagentWarehouse = [];
  Reagent? selectedReagent;
  int? quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
      body: _buildReagentWarehouse(),
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

  Widget _buildReagentWarehouse() {
    return Column(
      children: [
        _buildInterfaceReagentWarehouse(),
        Expanded(child: _buildResources())
      ],
    );
  }

  Widget _buildInterfaceReagentWarehouse() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAddToReagentWarehouseButton(),
          ElevatedButton(
              onPressed: () {
                if (reagentWarehouse.isNotEmpty) {
                  RecipeModel recipe = RecipeModel(status: false, reagents: reagentWarehouse);
                  RecipeRepository().insertRecipe(recipe);
                  setState(() {
                    reagentWarehouse.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
              ),
              child: const Text(
                'Оформить рецепт',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  Widget _buildAddToReagentWarehouseButton() {
    return ElevatedButton(
      onPressed: _showAddToReagentWarehouseDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[300],
      ),
      child: const Text(
        'Добавить в рецепт',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showAddToReagentWarehouseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        selectedReagent = null;
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
                _buildAddToReagentWarehouseDialogButton(),
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

  Widget _buildAddToReagentWarehouseDialogButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedReagent != null && quantity != null) {
          ReagentWarehouse newReagent = ReagentWarehouse(
            reagentId: selectedReagent!.id!,
            quantity: quantity!,
          );
          setState(() {
            reagentWarehouse.add(newReagent);
          });
          Navigator.of(context).pop();
        } else {
          _showErrorDialog();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[300],
      ),
      child: const Text(
        'Добавить в рецепт',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
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
    return ListView.builder(
      itemCount: reagentWarehouse.length,
      itemBuilder: (context, index) {
        ReagentWarehouse element = reagentWarehouse[index];
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
                  _showUpdateReagentWarehouseDialog(element, index);
                },
                icon: const Icon(Icons.add_home_rounded, size: 40),
              ),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              reagentWarehouse.removeAt(index);
            });
          },
        );
      },
    );
  }

  void _showUpdateReagentWarehouseDialog(ReagentWarehouse element, int index) {
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
                _buildUpdateReagentWarehouseDialogButton(element, index),
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
        labelText: 'Введите количество',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildUpdateReagentWarehouseDialogButton(
      ReagentWarehouse element, int index) {
    return ElevatedButton(
      onPressed: () {
        if (quantity != null) {
          ReagentWarehouse newReagent = ReagentWarehouse(
            reagentId: element.reagentId,
            quantity: quantity!,
          );
          setState(() {
            reagentWarehouse[index] = newReagent;
          });
          Navigator.of(context).pop();
        } else {
          _showErrorDialog();
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
}
