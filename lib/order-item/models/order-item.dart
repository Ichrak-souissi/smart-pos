import 'package:pos/ingredient/models/ingredient.dart';
import 'package:pos/supplement/models/supplement.dart';

class OrderItem {
  int ?id;
  int orderId ;
  String name;
  double price;
  int quantity;
  List<Ingredient> ingredients;
  List<Supplement> supplements;

  OrderItem({
     this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.orderId,
    required this.ingredients,
    required this.supplements,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      price: (json["price"] ?? 0).toDouble(),
      quantity: json["quantity"] ?? 0,
      orderId: json ["orderId"]?? 0,
      ingredients: (json["ingredients"] != null)
          ? List<Ingredient>.from(json["ingredients"].map((x) => Ingredient.fromJson(x)))
          : [],
      supplements: (json["supplements"] != null)
          ? List<Supplement>.from(json["supplements"].map((x) => Supplement.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "quantity": quantity,
        "orderId": orderId, 
        "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
        "supplements": List<dynamic>.from(supplements.map((x) => x.toJson())),
      };

}
