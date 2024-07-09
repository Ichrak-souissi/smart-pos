import 'package:get/get.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/category/models/category.dart';
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
    returnOrderItems().then((value) {
      findMostOrderedItems(value);
    });
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

  void findMostOrderedItems(List<OrderItem> orderItems) {
    try {
      if (orderItems.isNotEmpty) {
        orderItems.sort((a, b) => b.quantity.compareTo(a.quantity));
        mostOrderedItems.assignAll(orderItems);

        print('Articles les plus commandés :');
        for (var item in mostOrderedItems) {
          print('Nom: ${item.name}, Quantité: ${item.quantity}');
        }
      } else {
        //mostOrderedItems.clear();
        print('Aucun article commandé pour le moment.');
      }
    } catch (e) {
      print('Erreur: $e');
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
        findMostOrderedItems(orderItems);

        update();

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
      findMostOrderedItems(orderItems);
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
        findMostOrderedItems(orderItemsList);

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
