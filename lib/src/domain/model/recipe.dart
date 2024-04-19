import 'package:accounting_chemical_reagents/src/domain/model/reagent_warehouse.dart';

class RecipeModel {
  final int? id;
  final bool status;
  final List<ReagentWarehouse> reagents;

  const RecipeModel({
      this.id,
      required this.status,
      required this.reagents});

  Map<String, Object?> toMap() {
    List<Map<String, Object?>> reagentsMap = reagents.map((reagentWarehouse) => reagentWarehouse.toMap()).toList();

    return {
      'status': status ? 1 : 0,
      };
  }

  static RecipeModel fromMap(Map<String, dynamic> map) {
    List<dynamic> reagentsList = map['reagents'];
    List<ReagentWarehouse> reagents = reagentsList.map((reagentMap) => ReagentWarehouse.fromMap(reagentMap)).toList();

    return RecipeModel(
      id: map['id'],
      status: map['status'] == 1,
      reagents: reagents,
    );
  }
}
