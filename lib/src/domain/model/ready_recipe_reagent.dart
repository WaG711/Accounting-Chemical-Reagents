class ReadyRecipeReagent {
  final int readyRecipeId;
  final int reagentId;
  final int quantity;

  const ReadyRecipeReagent(
      {required this.readyRecipeId,
      required this.reagentId,
      required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': readyRecipeId,
      'reagent_id': reagentId,
      'quantity': quantity,
    };
  }

  static ReadyRecipeReagent fromMap(Map<String, dynamic> map) {
    return ReadyRecipeReagent(
      readyRecipeId: map['ready_recipe_id'],
      reagentId: map['reagent_id'],
      quantity: map['quantity'],
    );
  }
}
