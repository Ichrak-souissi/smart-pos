import '../../ingredient/models/ingredient.dart';
import '../../supplement/models/supplement.dart';

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
  List<Supplement> supplements;
  int? discount; 

  Item({
    required this.id,
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
    required this.supplements,
    this.discount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      description: json["description"] ?? '',
      price: (json["price"] ?? 0).toDouble(),
      imageUrl: json["imageUrl"] ?? '',
      calories: json["calories"] ?? 0,
      isActive: json["isActive"] ?? false,
      duration: json["duration"] ?? 0,
      categoryId: json["categoryId"] ?? 0,
      createdAt: DateTime.parse(json["createdAt"] ?? ''),
      ingredients: (json["ingredients"] != null)
          ? List<Ingredient>.from(json["ingredients"].map((x) => Ingredient.fromJson(x)))
          : [],
      supplements: (json["supplements"] != null)
          ? List<Supplement>.from(json["supplements"].map((x) => Supplement.fromJson(x)))
          : [],
      discount: json["discount"], 
    );
  }

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
        "supplements": List<dynamic>.from(supplements.map((x) => x.toJson())),
        "discount": discount, 
      };
}
