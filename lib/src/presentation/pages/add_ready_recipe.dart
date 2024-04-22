import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe_reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagents_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class AddReadyRecipe extends StatefulWidget {
  const AddReadyRecipe({super.key});

  @override
  State<AddReadyRecipe> createState() => _AddReadyRecipeState();
}

class _AddReadyRecipeState extends State<AddReadyRecipe> {
  final TextEditingController _textEditingController = TextEditingController();
  List<ReagentsRecipe> reagentsReadyRecipe = [];
  Reagent? selectedReagent;
  int? quantity;
  String name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: MyWidgets.buildDrawer(context),
      body: _buildReagentsReadyRecipe(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Добавить готовый рецепт',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue[300],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildReagentsReadyRecipe() {
    return Column(
      children: [
        Expanded(child: _buildResources()),
        _buildRowNameReadyRecipe(),
        _buildInterfaceReagentsReadyRecipe()
      ],
    );
  }

  Widget _buildResources() {
    if (reagentsReadyRecipe.isEmpty) {
      return const Center(
        child: Text(
          'Добавьте реагент',
          style: TextStyle(fontSize: 28),
        ),
      );
    }

    return ListView.builder(
      itemCount: reagentsReadyRecipe.length,
      itemBuilder: (context, index) {
        ReagentsRecipe element = reagentsReadyRecipe[index];
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
                  _showUpdateReagentsReadyRecipeDialog(element, index);
                },
                icon: const Icon(Icons.change_circle_rounded, size: 40),
              ),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              reagentsReadyRecipe.removeAt(index);
            });
          },
        );
      },
    );
  }

  void _showUpdateReagentsReadyRecipeDialog(ReagentsRecipe element, int index) {
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
                  child: _buildUpdateReagentsReadyRecipeDialogButton(
                      element, index),
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

  Widget _buildUpdateReagentsReadyRecipeDialogButton(
      ReagentsRecipe element, int index) {
    return ElevatedButton(
      onPressed: () {
        if (quantity != null) {
          ReagentsRecipe newReagent = ReagentsRecipe(
            reagentId: element.reagentId,
            quantity: quantity!,
          );
          setState(() {
            reagentsReadyRecipe[index] = newReagent;
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

  Widget _buildRowNameReadyRecipe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 1, 20, 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(labelText: 'Название готового рецепта'),
            onChanged: (value) {
              name = value;
            },
          )
        ],
      ),
    );
  }

  Widget _buildInterfaceReagentsReadyRecipe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 10, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAddReadyRecipeButton(),
          _buildAddToReagentsReadyRecipeButton()
        ],
      ),
    );
  }

  Widget _buildAddToReagentsReadyRecipeButton() {
    return IconButton(
      onPressed: _showAddToReagentsReadyRecipeDialog,
      icon: const Icon(
        Icons.add_rounded,
        size: 40,
      ),
    );
  }

  void _showAddToReagentsReadyRecipeDialog() {
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
                _buildAddToReagentsReadyRecipeDialogButton(),
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

  Widget _buildAddToReagentsReadyRecipeDialogButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedReagent != null && quantity != null) {
          int existingIndex = reagentsReadyRecipe.indexWhere((element) => element.reagentId == selectedReagent!.id);

          if (existingIndex != -1) {
            setState(() {
              reagentsReadyRecipe[existingIndex].quantity += quantity!;
            });
          } else {
            ReagentsRecipe newReagent = ReagentsRecipe(
              reagentId: selectedReagent!.id!,
              quantity: quantity!,
            );
            setState(() {
              reagentsReadyRecipe.add(newReagent);
            });
          }
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

  Widget _buildAddReadyRecipeButton() {
    return ElevatedButton(
        onPressed: () {
          if (reagentsReadyRecipe.isNotEmpty && name.isNotEmpty) {
            _addReadyRecipeReagent();
          } else {
            _showErrorDialog();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
        ),
        child: const Text(
          'Сохранить рецепт',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ));
  }

  Future<void> _addReadyRecipeReagent() async {
    ReadyRecipeModel readyRecipe = ReadyRecipeModel(name: name);
    int readyRecipeId = await ReadyRecipeRepository().insertReadyRecipe(readyRecipe);

    for (var element in reagentsReadyRecipe) {
      ReadyRecipeReagent readyRecipeReagent = ReadyRecipeReagent(
          readyRecipeId: readyRecipeId,
          reagentId: element.reagentId,
          quantity: element.quantity);
      await ReadyRecipeReagentRepository().insertReadyRecipeReagent(readyRecipeReagent);
    }
    setState(() {
      reagentsReadyRecipe.clear();
      _textEditingController.clear();
    });
  }
}
