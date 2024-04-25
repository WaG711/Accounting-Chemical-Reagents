import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:flutter/material.dart';

class MyWidgets {
  static void openBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.receipt_rounded,
                  size: 34,
                  color: Colors.blue[300],
                ),
                title: const Text(
                  'Собрать рецепт',
                  style: TextStyle(fontSize: 24),
                ),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/recipe', (route) => false);
                },
              ),
              ListTile(
                leading: Icon(Icons.warehouse_rounded,
                    size: 34, color: Colors.green[300]),
                title: const Text(
                  'Управление складом',
                  style: TextStyle(fontSize: 24),
                ),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/warehouse', (route) => false);
                },
              ),
              ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    size: 34, color: Colors.red[300]),
                title: const Text(
                  'Создать реагент',
                  style: TextStyle(fontSize: 24),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String name = '';
                      String formula = '';
                      return AlertDialog(
                        title: const Center(
                          child: Text('Создайте реагент'),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration: buildInputDecoration('Название'),
                              onChanged: (value) {
                                name = value;
                              },
                            ),
                            TextField(
                              decoration: buildInputDecoration('Формула'),
                              onChanged: (value) {
                                formula = value;
                              },
                            ),
                          ],
                        ),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (name.isNotEmpty && formula.isNotEmpty) {
                                  Reagent reagent = Reagent(
                                    name: name.trim(),
                                    formula: formula.trim(),
                                  );
                                  ReagentRepository().insertReagent(reagent);
                                  Navigator.of(context).pop();
                                } else {
                                  buildErorDialog(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[300],
                              ),
                              child: const Text(
                                'Создать реагент',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10)
            ],
          ),
        );
      },
    );
  }

  static void buildErorDialog(BuildContext context) {
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

  static InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelText: text,
      labelStyle: const TextStyle(color: Colors.black),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }
}
