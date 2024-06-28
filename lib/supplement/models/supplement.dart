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
  factory Supplement.fromJson(Map<String, dynamic> json) => Supplement(
        name: json["name"],
        itemId: json["itemId"],
        id: json["id"],
        price: json["price"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "itemId": itemId,
        "id": id,
        "price": price,
      };
}
