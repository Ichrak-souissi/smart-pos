class Supplement {
  int id;
  String name;
  bool active;
  int itemId;
  int price;

  Supplement({
    required this.name,
    required this.itemId,
    required this.id,
    required this.active,
    required this.price, 
  });

  factory Supplement.fromJson(Map<String, dynamic> json) => Supplement(
        name: json["name"]?? '',
        itemId: json["itemId"]?? 0,
        id: json["id"]?? 0,
        active: json["active"]?? null ,
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "itemId": itemId,
        "id": id,
        "active": active,
        "price": price, 
      };
}
