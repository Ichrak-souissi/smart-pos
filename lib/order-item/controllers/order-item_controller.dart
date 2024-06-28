import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/category/controllers/category_controller.dart'; // Assurez-vous d'importer le contrôleur de catégorie
import 'package:pos/category/models/category.dart'; // Assurez-vous d'importer le modèle de catégorie
import 'package:pos/constants.dart';
import 'package:pos/order-item/models/order-item.dart';

class OrderItemController extends GetxController {
  RxBool isLoading = false.obs;
  final ClientDio _clientDio = ClientDio();
  final CategoryController categoryController = Get.put(CategoryController());

  List<OrderItem> orderItems = <OrderItem>[];
  RxList<OrderItem> mostOrderedItems = <OrderItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    findMostOrderedItems();
  }

  Future<List<OrderItem>> returnOrderItems() async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(Constants.getOrderItemUrl());
      if (response.statusCode == 200) {
        var orderItemsList = (response.data as List)
            .map((item) => OrderItem.fromJson(item))
            .toList();
        orderItems.assignAll(orderItemsList);
        return orderItemsList;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<OrderItem>> findMostOrderedItems() async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(Constants.getOrderItemUrl());
      if (response.statusCode == 200) {
        var orderItemsList = (response.data as List)
            .map((item) => OrderItem.fromJson(item))
            .toList();

        orderItemsList.sort((a, b) => b.quantity.compareTo(a.quantity));
        mostOrderedItems.assignAll(orderItemsList);
      } else {
        throw Exception('Failed to load order items');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
    return mostOrderedItems;
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

  void updateQuantity(OrderItem orderItem, int newQuantity) {
    final index = orderItems.indexWhere((item) => item.id == orderItem.id);

    if (index != -1) {
      orderItems[index].quantity = newQuantity;
      orderItems[index].price = orderItems[index].price * newQuantity;

      update();
    }
  }

  Future<List<OrderItem>> fetchOrderItemsByOrderId(String orderId) async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio
          .get('${Constants.getOrderItemUrl()}/order/$orderId');
      if (response.statusCode == 200) {
        var orderItemsList = (response.data as List)
            .map((item) => OrderItem.fromJson(item))
            .toList();
        orderItems.assignAll(orderItemsList);
        return orderItemsList;
      } else {
        throw Exception('Failed to load order items for orderId: $orderId');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
