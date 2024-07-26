import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pos/supplement/models/supplement.dart';

class Item {
  int id;
  String name;
  String description;
  double price;
  String imageUrl;
  int calories;
  bool isActive;
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
      categoryId: json["categoryId"] ?? 0,
      createdAt: json["createdAt"] != null && json["createdAt"] is String
          ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
          : DateTime.now(),
      discount: json["discount"],
      supplements: (json["supplements"] as List<dynamic>?)
          ?.map((supplementJson) => Supplement.fromJson(supplementJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "imageUrl": imageUrl,
      "calories": calories,
      "isActive": isActive,
      "categoryId": categoryId,
      "discount": discount,
      //  "supplements":
      //      supplements?.map((supplement) => supplement.toJson()).toList(),
    };

    return json;
  }

  Item copyWith({
    int? id,
    String? name,
    double? price,
    int? calories,
    String? description,
    String? imageUrl,
    int? categoryId,
    DateTime? createdAt,
    int? discount,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      calories: calories ?? this.calories,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      discount: discount ?? this.discount,
    );
  }
}
