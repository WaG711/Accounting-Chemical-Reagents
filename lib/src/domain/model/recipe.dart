class RecipeModel {
  final int? id;
  final bool isAccepted;
  final bool isEnough;

  const RecipeModel({this.id, required this.isAccepted, required this.isEnough});

  Map<String, Object?> toMap() {
    return {
      'isAccepted': isAccepted ? 1 : 0,
      'isEnough': isEnough ? 1 : 0,};
  }

  static RecipeModel fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'],
      isAccepted: map['isAccepted'] == 1,
      isEnough: map['isEnough'] == 1
    );
  }
}
