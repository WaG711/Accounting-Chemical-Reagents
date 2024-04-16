class Warehouse {
  final int reagentId;
  final int quantity;

  Warehouse({
      required this.reagentId,
      required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'reagentId': reagentId,
      'quantity': quantity,
    };
  }
}