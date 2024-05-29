class OrderItem {
  int? id;
  String name;
  double price;
  int quantity;
  String note;

  OrderItem({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json["id"],
      name: json["name"] ?? '',
      price: (json["price"] ?? 0).toDouble(),
      quantity: json["quantity"] ?? 0,
      note: json["note"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "quantity": quantity,
        "note": note,
      };
}
