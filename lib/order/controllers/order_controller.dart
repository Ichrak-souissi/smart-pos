import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/order/models/order.dart';

class OrderController extends GetxController {
  RxBool isLoadingOrders = false.obs;
  final ClientDio _clientDio = ClientDio();
  RxList<Order> orders = <Order>[].obs;
Future<List<Order>> fetchOrdersByTableId(String tableId) async {
    try {
      isLoadingOrders.value = true;
      final response = await _clientDio.dio.get(Constants.getOrdersByTableIdUrl(tableId));
      if (response.statusCode == 200) {
        var orderList = (response.data as List).map((order) => Order.fromJson(order)).toList();
        orders.assignAll(orderList);
        return orderList;
      } else {
        throw Exception('Failed to load orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    } finally {
      isLoadingOrders.value = false;
    }
  }
  Future<Order> addOrder(Order order) async {
    try {
      isLoadingOrders.value = true;
      final response = await _clientDio.dio.post(
        Constants.addOrderUrl(),
        data: order.toJson(),
      );
      if (response.statusCode == 201) { 
        return Order.fromJson(response.data);
      } else {
        throw Exception('Failed to add order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    } finally {
      isLoadingOrders.value = false;
    }
  }
}
