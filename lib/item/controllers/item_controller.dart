import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/item/models/item.dart';

class ItemController extends GetxController {
  final Dio _clientDio = Dio();
  final RxList<Item> categoryItems = <Item>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      final response = await _clientDio.get(Constants.getItemUrl());
      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = response.data;
        final List<Item> loadedItems =
            itemsJson.map((itemJson) => Item.fromJson(itemJson)).toList();
        categoryItems.value = loadedItems;
        errorMessage.value = '';
      } else {
        errorMessage.value = 'Failed to fetch items: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error occurred while fetching items: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Item?> updateItem(Item updatedItem) async {
    try {
      final String url = Constants.updateItemUrl(updatedItem.id.toString());
      final response = await _clientDio.patch(
        url,
        data: updatedItem.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final Item item = Item.fromJson(response.data);
        final index = categoryItems.indexWhere((i) => i.id == item.id);

        if (index != -1) {
          categoryItems[index] = item;
        }

        errorMessage.value = '';
        return item;
      } else {
        errorMessage.value = 'Failed to update item: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Error occurred while updating item: $e';
      return null;
    }
  }
}
