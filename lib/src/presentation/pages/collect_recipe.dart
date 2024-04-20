import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagents_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe_reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class CollectRecipe extends StatefulWidget {
  const CollectRecipe({super.key});

  @override
  State<CollectRecipe> createState() => _CollectRecipStateState();
}

class _CollectRecipStateState extends State<CollectRecipe> {
  List<ReagentsRecipe> reagentsRecipe = [];
  Reagent? selectedReagent;
  int? quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
      body: _buildReagentsRecipe(),
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

  Widget _buildReagentsRecipe() {
    return Column(
      children: [
        Expanded(child: _buildResources()),
        _buildInterfaceReagentsRecipe()
      ],
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
        });
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

  Widget _buildAddToReagentsRecipeDialogButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedReagent != null && quantity != null) {
          ReagentsRecipe newReagent = ReagentsRecipe(
            reagentId: selectedReagent!.id!,
            quantity: quantity!,
          );
          setState(() {
            reagentsRecipe.add(newReagent);
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

  Widget _buildOrderRecipeButton() {
    return ElevatedButton(
        onPressed: () {
          if (reagentsRecipe.isNotEmpty) {
            _addRecipeReagent(reagentsRecipe);
          } else {
            _showErrorDialog();
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
          return const AlertDialog();
        });
  }

  Widget _buildResources() {
    return ListView.builder(
      itemCount: reagentsRecipe.length,
      itemBuilder: (context, index) {
        ReagentsRecipe element = reagentsRecipe[index];
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
                  _showUpdateReagentsRecipeDialog(element, index);
                },
                icon: const Icon(Icons.change_circle_rounded, size: 40),
              ),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              reagentsRecipe.removeAt(index);
            });
          },
        );
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

  Widget _buildUpdateReagentsRecipeDialogButton(ReagentsRecipe element, int index) {
    return ElevatedButton(
      onPressed: () {
        if (quantity != null) {
          ReagentsRecipe newReagent = ReagentsRecipe(
            reagentId: element.reagentId,
            quantity: quantity!,
          );
          setState(() {
            reagentsRecipe[index] = newReagent;
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

  Future<void> _addRecipeReagent(List<ReagentsRecipe> reagentsRecipe) async {
    RecipeModel recipe = const RecipeModel(isAccepted: false, isEnough: true);
    int recipeId = await RecipeRepository().insertRecipe(recipe);

    for (var element in reagentsRecipe) {
      RecipeReagent recipeReagent = RecipeReagent(
          recipeId: recipeId,
          reagentId: element.reagentId,
          quantity: element.quantity);
      await RecipeReagentRepository().insertRecipeReagent(recipeReagent);
    }
    setState(() {
      reagentsRecipe.clear();
    });
  }
}
