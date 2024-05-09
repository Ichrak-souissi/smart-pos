class Ingredient {
  int id;
  String name;
  bool active;
  int itemId;

  Ingredient({
    required this.name,
    required this.itemId,
    required this.active, 
    required this.id,
  });
factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
  name: json["name"],
  active: json["active"],
  itemId: json["itemId"], 
  id : json["id"],
);


  Map<String, dynamic> toJson() => {
    "name": name,
    "active": active,
    "itemId": itemId,
    "id":id,
  };
}
