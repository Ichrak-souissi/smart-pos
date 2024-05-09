import 'package:dio/dio.dart';
import 'package:pos/constants.dart';
import 'package:pos/ingredient/models/ingredient.dart';
import 'package:pos/supplement/models/supplement.dart';
class IngredientController {
  final Dio _clientDio = Dio();
  
  Future<Ingredient> updateIngredient(int ingredientId, bool active) async {
    try {
      final response = await _clientDio.patch(
        Constants.getUpdateIngredientUrl(ingredientId.toString()),
        data: {'active': active},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        return Ingredient.fromJson(responseData['ingredient']);
      } else {
        throw Exception('Failed to update ingredient: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error : $e');
    }
  }

Future<List<Supplement>> getSuppelmentsByItemId(int itemId) async {
  try {
    final response = await _clientDio.get(
      Constants.getSupplementByItemIdUrl(itemId.toString()),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> supplementsJson = response.data;
      final List<Supplement> supplements= supplementsJson.map((supplementsJson) => Supplement.fromJson(supplementsJson)).toList();
      return supplements;
    } else {
      throw Exception('Failed to get supplements by item ID');
    }
  } catch (e) {
    throw Exception('Error occurred while fetching supplements by item ID: $e');
  }
}
}
