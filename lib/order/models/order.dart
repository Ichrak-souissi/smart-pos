import 'package:pos/order-item/models/order-item.dart';

class Order {
  late final int id;
  late final int tableId;
  late final double total;
  late final List<OrderItem> orderItems;
  late int status;
  late final DateTime createdAt;
  late final bool isPaid;

  Order({
    required this.id,
    required this.tableId,
    required this.total,
    required this.orderItems,
    required this.status,
    required this.isPaid,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Order.fromJson(Map<String, dynamic>? json) {
    return Order(
      id: json?["id"] ?? 0,
      tableId: json?["tableId"] ?? 0,
      total: (json?["total"] ?? 0).toDouble(),
      orderItems: (json?["orderItems"] != null)
          ? List<OrderItem>.from(
              json?["orderItems"].map((x) => OrderItem.fromJson(x)) ?? [])
          : [],
      status: json?["status"] ?? 1,
      createdAt: json?["createdAt"] != null
          ? DateTime.parse(json?["createdAt"])
          : DateTime.now(),
      isPaid: json?["isPaid"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "tableId": tableId,
        "total": total,
        "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "status": status,
        "createdAt": createdAt.toIso8601String(),
        "isPaid": isPaid,
      };
}
