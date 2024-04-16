import 'package:flutter/material.dart';

class MyWidgets {
  static Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_rounded),
            title: const Text(
              'Собрать рецепт',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/recipe');
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse_rounded),
            title: const Text(
              'Управление складом',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/warehouse');
            },
          ),
        ],
      ),
    );
  }
}
