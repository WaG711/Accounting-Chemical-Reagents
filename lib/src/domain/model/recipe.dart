import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';

class Recipe {
  final int? id;
  final bool status;
  final List<Reagent> reagents;

  const Recipe({
      this.id,
      required this.status,
      required this.reagents});

  Map<String, Object?> toMap() {
    List<Map<String, Object?>> reagentsMap = reagents.map((reagent) => reagent.toMap()).toList();

    return {
      'status': status ? 1 : 0,
      'reagents': reagentsMap
      };
  }

  static Recipe fromMap(Map<String, dynamic> map) {
    List<dynamic> reagentsList = map['reagents'];
    List<Reagent> reagents = reagentsList.map((reagentMap) => Reagent.fromMap(reagentMap)).toList();

    return Recipe(
      id: map['id'],
      status: map['status'] == 1,
      reagents: reagents,
    );
  }
}
