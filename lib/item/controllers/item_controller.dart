import 'package:dio/dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/ingredient/models/ingredient.dart';

class ItemController {
  final Dio _clientDio = Dio();
Future<List<Ingredient>> getIngredientsByItemId(int itemId) async {
  try {
    final response = await _clientDio.get(
      Constants.getIngredientByItemIdUrl(itemId.toString()),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> ingredientsJson = response.data;
      final List<Ingredient> ingredients = ingredientsJson.map((ingredientJson) => Ingredient.fromJson(ingredientJson)).toList();
      return ingredients;
    } else {
      throw Exception('Failed to get ingredients by item ID');
    }
  } catch (e) {
    throw Exception('Error occurred while fetching ingredients by item ID: $e');
  }
}
}