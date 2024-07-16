import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/order-item/models/order-item.dart';

import '../models/item.dart';

class ItemController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Item> categoryItems = <Item>[].obs;

  final ClientDio _clientDio = ClientDio();

  @override
  void onInit() {
    super.onInit();
  }

  Future<Item?> updateItem(Item updatedItem) async {
    try {
      final dio = Dio();
      final url = Constants.updateItemUrl(updatedItem.id.toString());
      final response = await dio.patch(
        url,
        data: updatedItem.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final updatedItem = Item.fromJson(responseData);
        int index =
            categoryItems.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          categoryItems[index] = updatedItem;
          categoryItems.refresh();
        }
        return updatedItem;
      } else {
        print('Failed to update item: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating item: $e');
      return null;
    }
  }

  Future<void> deleteItem(int itemId) async {
    try {
      isLoading(true);
      final response = await _clientDio.dio.delete(
        Constants.deleteItemUrl(itemId.toString()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        categoryItems.removeWhere((item) => item.id == itemId);
      } else {
        print('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting item: $e');
    } finally {
      isLoading(false);
    }
  }
}
