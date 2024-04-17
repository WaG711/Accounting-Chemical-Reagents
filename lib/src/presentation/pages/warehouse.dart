import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
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
        title: const Text('Склад'),
      ),
      endDrawer: MyWidgets.buildDrawer(context),
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
                                  title: const Text("Ошибка"),
                                  content: const Text("Все поля должны быть заполнены"),
                                  actions: [
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("OK",
                                        style: TextStyle(
                                          color: Colors.black
                                        ),),
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
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
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add_home_rounded,
          size: 45,
        ),
      ),
    );
  }
}
