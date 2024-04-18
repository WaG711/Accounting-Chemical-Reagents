import 'package:flutter/material.dart';

class Entrance extends StatelessWidget {
  const Entrance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/recipe');
            },
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.blue[300]),
            child: const Text(
              'Собрать рецепт',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/warehouse');
            },
            child: const Text(
              'Управление складом',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
