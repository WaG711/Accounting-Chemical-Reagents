import 'package:flutter/material.dart';

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
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
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Navigator.pushNamed(context, '/warehouse');
            //Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Главный экран'),
          onTap: () {
            Navigator.pushNamed(context, '/order');
          },
        ),
        ListTile(
          leading: Icon(Icons.login),
          title: Text('Выйти'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    ),
  );
}