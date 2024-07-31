import 'package:pos/order/models/order.dart';

class Payment {
  final int id;
  final List<Order> orders;
  final double amount;

  Payment({
    required this.id,
    required this.orders,
    required this.amount,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      orders: (json['orders'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      amount: json['amount'] as double,
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
