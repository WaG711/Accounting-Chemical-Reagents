import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/warehouse.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/warehouse_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class WarehouseReagents extends StatefulWidget {
  const WarehouseReagents({super.key});

  @override
  State<WarehouseReagents> createState() => _WarehouseReagentsState();
}

class _WarehouseReagentsState extends State<WarehouseReagents> {
  late Future<List<WarehouseModel>> _fetchWarehouseFuture;
  Reagent? _selectedReagent;
  int? _quantity;

  @override
  void initState() {
    super.initState();
    _fetchWarehouseFuture = _fetchWarehouseData();
  }

  Future<List<WarehouseModel>> _fetchWarehouseData() async {
    return WarehouseRepository().getElements();
  }

  void _refreshWarehouseData() {
    setState(() {
      _fetchWarehouseFuture = _fetchWarehouseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildResources()),
          _buildButtonWarehouseResource(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Склад',
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

  Widget _buildResources() {
    return FutureBuilder<List<WarehouseModel>>(
      future: _fetchWarehouseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.green[300]));
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
                    color: const Color.fromARGB(255, 240, 255, 240),
                    child: ListTile(
                      title: FutureBuilder<Reagent>(
                        future: ReagentRepository()
                            .getReagentById(element.reagentId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(
                                color: Colors.green[300]);
                          } else if (snapshot.hasError) {
                            return Text('Ошибка: ${snapshot.error}');
                          } else {
                            return Text(
                                '${snapshot.data!.formula} • ${snapshot.data!.name}',
                                style: const TextStyle(fontSize: 21));
                          }
                        },
                      ),
                      subtitle: Text('Количество: ${element.quantity}',
                          style: const TextStyle(fontSize: 17)),
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
      decoration: MyWidgets.buildInputDecoration('Прибавить на'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildUpdateWarehouseDialogButton(WarehouseModel element) {
    return ElevatedButton(
      onPressed: () {
        if (_quantity != null) {
          WarehouseModel warehouse = WarehouseModel(
            id: element.id,
            reagentId: element.reagentId,
            quantity: element.quantity + _quantity!,
          );
          WarehouseRepository().updateElement(warehouse);
          _refreshWarehouseData();
          Navigator.of(context).pop();
        } else {
          MyWidgets.buildErorDialog(context);
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

  Widget _buildButtonWarehouseResource() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 1, 10, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildAddToWarehouseButton()],
        ));
  }

  Widget _buildAddToWarehouseButton() {
    return ElevatedButton(
      onPressed: _showAddToWarehouseDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
      ),
      child: const Text(
        'Добавить на склад',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }

  void _showAddToWarehouseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        _selectedReagent = null;
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
            value: _selectedReagent?.id,
            items: reagents.map((reagent) {
              return DropdownMenuItem<int>(
                value: reagent.id,
                child: Text(reagent.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedReagent =
                    reagents.firstWhere((reagent) => reagent.id == value);
              });
            },
            decoration: MyWidgets.buildInputDecoration('Выберите реагент'),
            isExpanded: true,
          );
        }
      },
    );
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

  Widget _buildAddToWarehouseDialogButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_selectedReagent != null && _quantity != null) {
            _addToWarehouse();
            Navigator.of(context).pop();
          } else {
            MyWidgets.buildErorDialog(context);
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
    );
  }

  Future<void> _addToWarehouse() async {
    WarehouseModel? existingWarehouse = await WarehouseRepository()
        .getElementByReagentId(_selectedReagent!.id!);

    if (existingWarehouse != null) {
      WarehouseModel warehouse = WarehouseModel(
        id: existingWarehouse.id,
        reagentId: existingWarehouse.reagentId,
        quantity: existingWarehouse.quantity + _quantity!,
      );
      WarehouseRepository().updateElement(warehouse);
    } else {
      WarehouseModel warehouse = WarehouseModel(
        reagentId: _selectedReagent!.id!,
        quantity: _quantity!,
      );
      WarehouseRepository().insertElement(warehouse);
    }
    _refreshWarehouseData();
  }
}
