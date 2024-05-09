import 'dart:convert';
import 'package:pos/item/models/item.dart';


Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  int id;
  String imageUrl;
  String name;
  bool isActive;
  List<Item> items; 

  Category({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.isActive,
    required this.items, 
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        imageUrl: json["imageUrl"],
        isActive: json["isActive"],
        items: (json["items"] != null)
            ? List<Item>.from(json["items"].map((x) => Item.fromJson(x)))
            : [], 
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "imageUrl": imageUrl,
        "isActive": isActive,
        "items": List<dynamic>.from(items.map((x) => x.toJson())), 
      };
}
