import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pos/constants.dart';
import 'package:pos/order/models/order.dart';

class PaymentController extends GetxController {
  final Dio _dio = Dio();
  final RxList<Order> _orders = <Order>[].obs;

  List<Order> get orders => _orders.toList();

  double get amount => _orders.fold(0.0, (sum, order) => sum + order.total);

  Future<void> fetchPayments() async {
    try {
      final response = await _dio.get(Constants.getPayments());
      if (response.statusCode == 200) {
        print('Payments fetched successfully');
      } else {
        print('Failed to fetch payments: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to fetch payments');
      }
    } catch (e) {
      print('Error fetching payments: $e');
      Get.snackbar('Error', 'Failed to fetch payments');
    }
  }

  Future<void> createPayment() async {
    try {
      final response = await _dio.post(
        Constants.addPaymentUrl(),
        data: {
          'orders': _orders.map((order) => order.toJson()).toList(),
          'amount': amount,
        },
      );
      if (response.statusCode == 201) {
        print('Payment created successfully');
        Get.snackbar('Success', 'Payment created successfully');
      } else {
        print('Failed to create payment: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to create payment');
      }
    } catch (e) {
      print('Error creating payment: $e');
      Get.snackbar('Error', 'Error creating payment');
    }
  }

  void addOrder(Order order) {
    if (!_orders.contains(order)) {
      _orders.add(order);
    }
  }

  void removeOrder(Order order) {
    _orders.remove(order);
  }

  Future<void> submitPayment() async {
    if (_orders.isEmpty) {
      Get.snackbar('Error', 'Please add at least one order.');
      return;
    }

    await createPayment();
  }
}
