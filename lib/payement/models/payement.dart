import 'package:pos/order/models/order.dart';

class Payment {
  final int id;
  final List<Order> orders;
  final double amount; // New attribute

  Payment({
    required this.id,
    required this.orders,
    required this.amount, // Include the new attribute in the constructor
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      orders: (json['orders'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      amount: json['amount'] as double, // Parse the amount from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orders': orders.map((order) => order.toJson()).toList(),
      'amount': amount, // Include the amount in the JSON output
    };
  }
}
