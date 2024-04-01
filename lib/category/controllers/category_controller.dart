import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos/category/models/category.dart';

import '../../Dio/client_dio.dart';
import '../../constants.dart';

class CategoryController extends GetxController {
  RxList<Category> categoryList = <Category>[].obs;
  final ClientDio _clientDio = ClientDio();

  Future<void> getCategoryList() async {
    try {
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
        final List<Category> categories = categoriesJson.map((categoryJson) =>
            Category.fromJson(categoryJson)).toList();
        categoryList.assignAll(categories);
        print(categoryList);
      } else {
        print('Failed to get category list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching category list: ${e.toString()}');
    }
  }
}
