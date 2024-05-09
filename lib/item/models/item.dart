import 'package:pos/ingredient/models/ingredient.dart';

class Item {
    int id;
  String name;
  String description;
  double price;
  String imageUrl;
  int calories;
  bool isActive;
  int duration;
  int categoryId;
  DateTime createdAt;
  List<Ingredient> ingredients; 

  Item({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.calories,
    this.isActive = true,
    required this.duration,
    required this.categoryId,
    required this.createdAt,
    required this.ingredients, 
    required this.id 
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
            id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"].toDouble(),
        imageUrl: json["imageUrl"],
        calories: json["calories"],
        isActive: json["isActive"],
        duration: json["duration"],
        categoryId: json["categoryId"],
        createdAt: DateTime.parse(json["createdAt"]),
        ingredients: (json["ingredients"] != null)
            ? List<Ingredient>.from(json["ingredients"].map((x) => Ingredient.fromJson(x))) 
            : [],
      );

  Map<String, dynamic> toJson() => {
            "id": id,
        "name": name,
        "description": description,
        "price": price,
        "imageUrl": imageUrl,
        "calories": calories,
        "isActive": isActive,
        "duration": duration,
        "categoryId": categoryId,
        "createdAt": createdAt.toIso8601String(),
        "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())), 
      };
}
