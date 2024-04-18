class Reagent {
  final int? id;
  final String name;
  final String formula;

  const Reagent({
      this.id,
      required this.name,
      required this.formula});

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'formula': formula
      };
  }

  static Reagent fromMap(Map<String, dynamic> map) {
    return Reagent(
      id: map['id'],
      name: map['name'],
      formula: map['formula'],
    );
  }
}
