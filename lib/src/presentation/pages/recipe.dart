import 'package:flutter/material.dart';

class Recipe extends StatelessWidget {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор рецепта'),
      ));}
      /*body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('recipes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<QueryDocumentSnapshot> recipes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe['name']),
                subtitle: Text(
                    'Количество ингредиентов: ${recipe['ingredients'].length}'),
                onTap: () {
                  _addToOrder(context, recipe);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _addToOrder(BuildContext context, QueryDocumentSnapshot recipe) {
    List<Map<String, dynamic>> ingredients = [];
    recipe['ingredients'].forEach((ingredient) {
      ingredients.add({
        'id': ingredient['id'],
        'name': ingredient['name'],
        'quantity': ingredient['quantity'],
      });
    });
    Navigator.pop(context, ingredients);
  }*/
}
