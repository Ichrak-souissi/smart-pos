import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/order-item/models/order-item.dart';

class OrderItemController extends GetxController {
  RxBool isLoading = false.obs;
  final ClientDio _clientDio = ClientDio();
  List<OrderItem> orderItems = <OrderItem>[];


  Future<List<OrderItem>> returnOrderItems() async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(Constants.getOrderItemUrl());
      if (response.statusCode == 200) {
        var orderItemsList = (response.data as List).map((item) => OrderItem.fromJson(item)).toList();
        orderItems.assignAll(orderItemsList);
        return orderItemsList;
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
Future<OrderItem> addOrderItem(OrderItem orderItem) async {
  try {
    isLoading.value = true;
    final response = await _clientDio.dio.post(
      Constants.addOrderItemUrl(),
      data: orderItem.toJson(),
    );
    print('Response status code: ${response.statusCode}');
    print('Response data: ${response.data}');
    
    if (response.statusCode == 200 || response.statusCode == 201) { 
      OrderItem newItem = OrderItem.fromJson(response.data);
      orderItems.add(newItem);
      return newItem;
    } else {
      throw Exception('Failed to add orderItem');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  } finally {
    isLoading.value = false;
  }
}

}