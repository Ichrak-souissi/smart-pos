class Supplement {
  int id;
  String name;
  int itemId;
  double price;

  Supplement({
    required this.name,
    required this.itemId,
    required this.id,
    required this.price,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      name: json["name"] ?? '',
      itemId: json["itemId"] ?? 0,
      id: json["id"] ?? 0,
      price: (json["price"] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "itemId": itemId,
      "id": id,
      "price": price,
    };
  }

  Supplement copyWith({
    int? id,
    String? name,
    int? itemId,
    double? price,
  }) {
    return Supplement(
      id: id ?? this.id,
      name: name ?? this.name,
      itemId: itemId ?? this.itemId,
      price: price ?? this.price,
    );
  }
}
