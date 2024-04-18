import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';

class ReadyRecipeModel {
  final int? id;
  final List<Reagent> reagents;

  const ReadyRecipeModel({
      this.id,
      required this.reagents});

  Map<String, Object?> toMap() {
    List<Map<String, Object?>> reagentsMap = reagents.map((reagent) => reagent.toMap()).toList();

    return {'reagents': reagentsMap};
  }
}
