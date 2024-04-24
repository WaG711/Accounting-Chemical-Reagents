import 'package:accounting_chemical_reagents/src/presentation/pages/collect_recipe.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/pending_recipes.dart';
import 'package:accounting_chemical_reagents/src/presentation/pages/ready_recipes.dart';
import 'package:flutter/material.dart';

class RecipeBase extends StatefulWidget {
  const RecipeBase({super.key});

  @override
  State<RecipeBase> createState() => _RecipeBaseState();
}

class _RecipeBaseState extends State<RecipeBase> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _buildSelectedContent(),
        bottomNavigationBar: _buildBottomNavigationBar());
  }

  Widget _buildSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return const ReadyRecipe();
      case 1:
        return const CollectRecipe();
      case 2:
        return const PendingRecipes();
      default:
        return const Text('Ошибка');
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded), label: 'Готовые'),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_rounded), label: 'Собрать'),
        BottomNavigationBarItem(
            icon: Icon(Icons.access_time_rounded), label: 'Ожидающие')
      ],
      selectedItemColor: Colors.blue[300],
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
    );
  }
}
