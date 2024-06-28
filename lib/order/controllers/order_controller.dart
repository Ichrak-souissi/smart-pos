import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/order/models/order.dart';

class OrderController extends GetxController {
  RxBool isLoadingOrders = false.obs;
  final ClientDio _clientDio = ClientDio();
  RxList<Order> orders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }

  int getTotalOrdersCount() {
    return orders.length;
  }

  Future<List<Order>> fetchOrdersByTableId(String tableId) async {
    try {
      isLoadingOrders.value = true;
      final url = Constants.getOrdersByTableIdUrl(tableId);
      print('Fetching orders for table ID: $tableId');
      print('Request URL: $url');
      final response = await _clientDio.dio.get(url);
      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200) {
        var orderList = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        orders.assignAll(orderList);
        print('Orders for table $tableId: $orderList');
        return orderList;
      } else {
        throw Exception(
            'Failed to load orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> fetchAllOrders() async {
    try {
      isLoadingOrders.value = true;
      final url = Constants.getAllOrdersUrl();
      print('Fetch all orders');
      print('Request URL: $url');
      final response = await _clientDio.dio.get(url);
      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200) {
        var orderList = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        orders.assignAll(orderList);
        print('All orders: $orderList');
      } else {
        throw Exception(
            'Failed to load all orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all orders: $e');
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
        throw Exception(
            'Failed to add order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    } finally {
      isLoadingOrders.value = false;
    }
  }
}
