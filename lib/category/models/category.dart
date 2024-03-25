import 'dart:convert';

Category tableFromJson(String str) => Category.fromJson(json.decode(str));

String tableToJson(Category data) => json.encode(data.toJson());

class Category {
  int id;
  String image;
  String name;
 bool active;

  Category({
    required this.id,
    required this.image,
    required this.name,
    required this.active,


  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "active": active,
  };
}
