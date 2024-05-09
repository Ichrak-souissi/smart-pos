class Supplement {
  int id;
  String name;
  int itemId;

  Supplement({
    required this.name,
    required this.itemId,
    required this.id,
  });
factory Supplement.fromJson(Map<String, dynamic> json) => Supplement(
  name: json["name"],
  itemId: json["itemId"], 
  id : json["id"],
);


  Map<String, dynamic> toJson() => {
    "name": name,
    "itemId": itemId,
    "id":id,
  };
}
