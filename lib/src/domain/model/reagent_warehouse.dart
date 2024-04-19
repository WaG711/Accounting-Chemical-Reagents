class ReagentWarehouse {
  final int? id;
  final int reagentId;
  final int quantity;

  ReagentWarehouse({this.id, required this.reagentId, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'reagent_id': reagentId,
      'quantity': quantity,
    };
  }

  static ReagentWarehouse fromMap(Map<String, dynamic> map) {
    return ReagentWarehouse(
      id: map['id'],
      reagentId: map['reagent_id'],
      quantity: map['quantity'],
    );
  }
}