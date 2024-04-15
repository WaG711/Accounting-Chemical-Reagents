import 'package:accounting_chemical_reagents/src/presentation/pages/recipe.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/buildDrawer.dart';
import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Заказ'),
        ),
        endDrawer: buildDrawer(context),
        body: Column(
          children: [
            Expanded(child: ListView.builder(
              //itemBuilder: ,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(''),
                  subtitle: const Text('Остаток на складе: {}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.remove_circle)),
                      IconButton(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.add_circle)),
                      IconButton(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.delete))
                    ],
                  ),
                );
              },
            )),
            ElevatedButton(
                onPressed: () async {}, child: const Text('Добавить реагент')),
            ElevatedButton(
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Recipe()));
                  //_addToCartFromRecipe();
                },
                child: const Text('Выбрать рецепт')),
            ElevatedButton(
                onPressed: () {
                  //_placeOrder();
                },
                child: const Text('Оформить заказ'))
          ],
        ));
  }
}
