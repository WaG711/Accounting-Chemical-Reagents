import 'package:flutter/material.dart';

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Меню',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pushNamed(context, '/warehouse');
            //Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          },
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Главный экран'),
          onTap: () {
            Navigator.pushNamed(context, '/order');
          },
        ),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Выйти'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    ),
  );
}