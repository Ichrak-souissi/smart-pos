import 'package:pos/supplement/models/supplement.dart';

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
  int? discount;
  List<Supplement>? supplements;

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
    this.discount,
    this.supplements,
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
      discount: json["discount"],
      supplements: (json["supplements"] as List<dynamic>?)
          ?.map((supplementJson) => Supplement.fromJson(supplementJson))
          .toList(),
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
        "discount": discount,
        "supplements":
            supplements?.map((supplement) => supplement.toJson()).toList(),
      };
}
