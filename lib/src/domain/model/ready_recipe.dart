import 'package:accounting_chemical_reagents/src/domain/model/reagent_warehouse.dart';

class ReadyRecipeModel {
  final int? id;
  final List<ReagentWarehouse> reagents;

  const ReadyRecipeModel({
      this.id,
      required this.reagents});

  Map<String, Object?> toMap() {
    List<Map<String, Object?>> reagentsMap = reagents.map((reagentWarehouse) => reagentWarehouse.toMap()).toList();

    return {};
  }
}
