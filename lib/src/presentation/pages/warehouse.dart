import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class Warehouse extends StatefulWidget {
  const Warehouse({super.key});

  @override
  State<Warehouse> createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {
  Reagent? selectedReagent;
  int? quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Склад',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[300],
          iconTheme: const IconThemeData(color: Colors.white)),
      endDrawer: MyWidgets.buildDrawer(context),
      body: StreamBuilder<List<Recipe>>(
        stream: Stream.fromFuture(RecipeRepository().getRecipes()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else {
            List<Recipe>? recipes = snapshot.data;
            if (recipes == null || recipes.isEmpty) {
              return const Center(child: Text(
                'Пусто',
                style: TextStyle(fontSize: 28),));
            } else {
              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  Recipe recipe = recipes[index];
                  return ListTile(
                    key: UniqueKey(),
                    title: Text('Рецепт ${recipe.id}'),
                    subtitle: Text('Реагенты: ${recipe.reagents.join(", ")}'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Принять'),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectedReagent = null;
          quantity = null;
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Center(
                      child: Text('Добавить на склад'),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FutureBuilder<List<Reagent>>(
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
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Количество',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              quantity = int.tryParse(value);
                            });
                          },
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          if (selectedReagent != null && quantity != null) {
                            Navigator.of(context).pop();
                          } else {
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[300],
                        ),
                        child: const Text(
                          'Добавить на склад',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        backgroundColor: Colors.green[300],
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add_home_rounded,
          size: 45,
        ),
      ),
    );
  }
}
