// ignore_for_file: empty_catches

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos/Dio/client_dio.dart';
import 'package:pos/category/models/category.dart';
import 'package:pos/constants.dart';
import 'package:pos/item/models/item.dart';

class CategoryController extends GetxController {
  RxList<Category> categoryList = <Category>[].obs;
  RxList<Item> categoryItems = <Item>[].obs;
  List<Item> originalItems = [];
  RxBool isLoading = false.obs;

  final ClientDio _clientDio = ClientDio();

  @override
  void onInit() {
    super.onInit();
    getCategoryList();
  }

  Future<List<Category>> getCategoryList() async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(
        Constants.getCategoryUrl(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = response.data;
        final List<Category> categories = categoriesJson
            .map((categoryJson) => Category.fromJson(categoryJson))
            .toList();

        categoryList.assignAll(categories);
        return categoryList;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  String getCategoryNameById(int id) {
    try {
      return categoryList.firstWhere((category) => category.id == id).name;
    } catch (e) {
      return 'Inconnu';
    }
  }

  Future<List<Item>> getItemsByCategoryId(int categoryId) async {
    try {
      isLoading.value = true;
      final response = await _clientDio.dio.get(
        Constants.getItemsByCategoryIdUrl(categoryId.toString()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = response.data;
        final List<Item> items =
            itemsJson.map((itemJson) => Item.fromJson(itemJson)).toList();

        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        originalItems = List.from(items);
        categoryItems.assignAll(items);
        return items;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching items by category ID: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void searchItemsByName(String query) {
    if (query.isEmpty) {
      categoryItems.assignAll(originalItems);
    } else {
      categoryItems.assignAll(originalItems.where(
          (item) => item.name.toLowerCase().contains(query.toLowerCase())));
    }
  }

  Future<void> addNewItem(Item newItem) async {
    try {
      final response = await _clientDio.dio.post(
        Constants.addItemUrl(),
        data: newItem.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 201) {
        categoryItems.add(newItem);
      } else {
        print('Failed to add new item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding new item: $e');
    }
  }

  void filterByPrice() {
    categoryItems.sort((a, b) => a.price.compareTo(b.price));
    update();
  }

  void filterAlphabetically() {
    categoryItems.sort((a, b) => a.name.compareTo(b.name));
    update();
  }

  void filterByCreationDate() {
    categoryItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    update();
  }
}
