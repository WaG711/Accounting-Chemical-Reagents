class ReadyRecipeModel {
  final int? id;
  final String name;

  const ReadyRecipeModel({this.id, required this.name});

  Map<String, Object?> toMap() {
    return {'name': name,};
  }

  static ReadyRecipeModel fromMap(Map<String, dynamic> map) {
    return ReadyRecipeModel(
      id: map['id'],
      name: map['name'],
    );
  }
}
