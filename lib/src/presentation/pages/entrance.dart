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
          FractionallySizedBox(
            widthFactor: 0.8,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/recipe');
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[300]),
              child: const Text(
                'Собрать рецепт',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: TextButton(
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
          )
        ],
      ),
    ));
  }
}
