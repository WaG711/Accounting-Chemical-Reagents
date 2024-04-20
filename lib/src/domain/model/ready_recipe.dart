class ReadyRecipeModel {
  final int? id;

  const ReadyRecipeModel({this.id});

  static ReadyRecipeModel fromMap(Map<String, dynamic> map) {
    return ReadyRecipeModel(
      id: map['id'],
    );
  }
}
