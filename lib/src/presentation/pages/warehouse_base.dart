import 'package:accounting_chemical_reagents/src/presentation/pages/warehouse_reagents.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/warehouse_recipes.dart';
import 'package:flutter/material.dart';

class WarehouseBase extends StatefulWidget {
  const WarehouseBase({super.key});

  @override
  State<WarehouseBase> createState() => _WarehouseBaseState();
}

class _WarehouseBaseState extends State<WarehouseBase> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _buildSelectedContent(),
        bottomNavigationBar: _buildBottomNavigationBar());
  }

  Widget _buildSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return const WarehouseReagents();
      case 1:
        return const WarehouseRecipes();
      default:
        return const Text('Ошибка');
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.warehouse_rounded), label: 'Склад'),
        BottomNavigationBarItem(
            icon: Icon(Icons.access_time_rounded), label: 'Рецепты'),
      ],
      selectedItemColor: Colors.green[300],
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
    );
  }
}