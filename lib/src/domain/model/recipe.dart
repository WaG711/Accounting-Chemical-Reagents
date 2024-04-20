class RecipeModel {
  final int? id;
  final bool status;

  const RecipeModel({this.id, required this.status});

  Map<String, Object?> toMap() {
    return {'status': status ? 1 : 0};
  }

  static RecipeModel fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'],
      status: map['status'] == 1,
    );
  }
}
