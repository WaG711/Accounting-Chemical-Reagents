class RecipeReagent {
  final int recipeId;
  final int reagentId;
  final int quantity;

  const RecipeReagent(
      {required this.recipeId,
      required this.reagentId,
      required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': recipeId,
      'reagent_id': reagentId,
      'quantity': quantity,
    };
  }

  static RecipeReagent fromMap(Map<String, dynamic> map) {
    return RecipeReagent(
      recipeId: map['recipe_id'],
      reagentId: map['reagent_id'],
      quantity: map['quantity'],
    );
  }
}
