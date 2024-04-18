class WarehouseModel {
  final int? id;
  final int reagentId;
  final int quantity;

  WarehouseModel({this.id, required this.reagentId, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'reagent_id': reagentId,
      'quantity': quantity,
    };
  }

  static WarehouseModel fromMap(Map<String, dynamic> map) {
    return WarehouseModel(
      id: map['id'],
      reagentId: map['reagent_id'],
      quantity: map['quantity'],
    );
  }
}
