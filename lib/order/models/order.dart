import 'package:pos/order-item/models/order-item.dart';

class Order {
  int id;
  int tableId;
  double total;
  String orderType ; 
  List<OrderItem> orderItems;
 String cooking;
  Order({
    required this.id,
    required this.tableId,
    required this.total,
    required this.orderItems,
    required this.orderType ,
    required this.cooking,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["id"] ?? 0,
      tableId: json["tableId"] ?? 0,
      total: (json["total"] ?? 0).toDouble(),
      orderItems: (json["orderItems"] != null)
          ? List<OrderItem>.from(json["orderItems"].map((x) => OrderItem.fromJson(x)))
          : [],
      orderType :json["orderType"]?? 'in dine',
      cooking: json["cooking"] ?? 'inProgress',

    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "tableId": tableId,
        "total": total,
        "orderType": orderType, 
        "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
         "cooking": cooking,

      };
}
